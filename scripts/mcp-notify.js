#!/usr/bin/env node
'use strict';

const fs = require('node:fs');
const path = require('node:path');

function readStdin() {
  try {
    return fs.readFileSync(0, 'utf8');
  } catch (error) {
    return '';
  }
}

function truncate(text, max = 300) {
  if (!text) return '';
  if (text.length <= max) return text;
  return `${text.slice(0, max - 3)}...`;
}

function parseRoute(value) {
  if (!value) return [];
  return value
    .split(/[,;\s]+/)
    .map((item) => item.trim().toLowerCase())
    .filter(Boolean);
}

function envKeyForEvent(eventName) {
  return `CLAUDE_NOTIFY_ROUTE_${eventName.replace(/[^a-zA-Z0-9]/g, '_').toUpperCase()}`;
}

function detectLevel(eventName, payload) {
  if (payload?.tool_response && payload.tool_response.success === false) {
    return 'error';
  }
  if (payload?.error) return 'error';
  if (eventName === 'Stop' || eventName === 'SubagentStop') return 'success';
  if (eventName === 'PreCompact') return 'warn';
  if (eventName === 'Notification') {
    const message = `${payload?.message || ''}`.toLowerCase();
    if (/(permission|confirm|allow|approve|授权|确认|允许)/i.test(message)) {
      return 'attention';
    }
    return 'info';
  }
  return 'info';
}

function buildMessage(eventName, payload, projectName) {
  const lines = [];
  const base = eventName ? `Event: ${eventName}` : 'Event: Unknown';

  if (eventName === 'Stop' || eventName === 'SubagentStop') {
    lines.push('任务已完成');
  } else if (eventName === 'Notification') {
    lines.push(payload?.message || 'Claude 需要确认');
  } else if (eventName === 'UserPromptSubmit') {
    lines.push('收到用户提示');
  } else if (eventName === 'PreToolUse') {
    lines.push(`准备使用工具: ${payload?.tool_name || 'unknown'}`);
  } else if (eventName === 'PostToolUse') {
    lines.push(`工具完成: ${payload?.tool_name || 'unknown'}`);
  } else {
    lines.push(base);
  }

  if (payload?.prompt) {
    lines.push(`Prompt: ${truncate(payload.prompt, 200)}`);
  }

  if (payload?.message && !lines.includes(payload.message)) {
    lines.push(truncate(payload.message, 300));
  }

  if (payload?.tool_response && payload.tool_response.success === false) {
    lines.push('Tool failed');
    if (payload.tool_response.error) {
      lines.push(`Error: ${truncate(String(payload.tool_response.error), 200)}`);
    }
  }

  if (projectName) {
    lines.push(`Project: ${projectName}`);
  }

  return lines.filter(Boolean).join('\n');
}

const CHANNEL_ENV_KEYS = {
  bark: [
    'BARK_PUSH',
    'BARK_ICON',
    'BARK_SOUND',
    'BARK_GROUP',
    'BARK_LEVEL',
    'BARK_URL',
    'BARK_ARCHIVE',
  ],
  telegram: [
    'TG_BOT_TOKEN',
    'TG_USER_ID',
    'TG_API_HOST',
    'TG_PROXY_AUTH',
    'TG_PROXY_HOST',
    'TG_PROXY_PORT',
  ],
  dingtalk: ['DD_BOT_TOKEN', 'DD_BOT_SECRET'],
  feishu: ['FSKEY', 'FSSECRET'],
  ntfy: [
    'NTFY_URL',
    'NTFY_TOPIC',
    'NTFY_PRIORITY',
    'NTFY_TOKEN',
    'NTFY_USERNAME',
    'NTFY_PASSWORD',
    'NTFY_ACTIONS',
  ],
};

function filterChannels(allowedChannels) {
  if (!allowedChannels.length || allowedChannels.includes('all')) {
    return;
  }

  const allowed = new Set(allowedChannels);
  for (const [channel, keys] of Object.entries(CHANNEL_ENV_KEYS)) {
    if (allowed.has(channel)) continue;
    for (const key of keys) {
      process.env[key] = '';
    }
  }
}

async function main() {
  const raw = readStdin().trim();
  if (!raw) return;

  let payload;
  try {
    payload = JSON.parse(raw);
  } catch (error) {
    console.error('[mcp-notify] Invalid JSON input');
    return;
  }

  const eventName = payload?.hook_event_name || 'Unknown';
  const cwd = payload?.cwd || process.cwd();
  const projectName = cwd ? path.basename(cwd) : '';
  const level = detectLevel(eventName, payload);
  const titleBase = process.env.CLAUDE_NOTIFY_TITLE || 'Claude Code';
  const title = projectName ? `${titleBase} · ${projectName}` : titleBase;

  const eventRoute = parseRoute(process.env[envKeyForEvent(eventName)]);
  const levelRoute = parseRoute(process.env[`CLAUDE_NOTIFY_ROUTE_${level.toUpperCase()}`]);
  const defaultRoute = parseRoute(process.env.CLAUDE_NOTIFY_ROUTE_DEFAULT);

  const defaultRoutes = {
    success: ['ntfy', 'bark'],
    error: ['telegram', 'dingtalk', 'feishu', 'ntfy'],
    attention: ['telegram', 'bark', 'dingtalk', 'feishu'],
    warn: ['ntfy', 'telegram'],
    info: ['ntfy'],
  };

  const route = eventRoute.length
    ? eventRoute
    : levelRoute.length
      ? levelRoute
      : defaultRoute.length
        ? defaultRoute
        : defaultRoutes[level] || [];

  filterChannels(Array.isArray(route) ? route : []);

  const message = buildMessage(eventName, payload, projectName);
  if (!message) return;

  const { sendNotify } = require(path.resolve(__dirname, '..', 'notify.js'));
  await sendNotify(title, message, { level, event: eventName });
}

main().catch((error) => {
  console.error('[mcp-notify] Failed to send notification', error);
});
