import { existsSync } from 'node:fs';
import { join } from 'node:path';
import type { CloudProvider, AIType } from '../types/index.js';

/**
 * Detect which AI IDE is being used based on environment
 */
export function detectAIType(): { detected: AIType[]; suggested: AIType | null } {
  const detected: AIType[] = [];
  const cwd = process.cwd();

  // Check for AI IDE folders
  if (existsSync(join(cwd, '.claude'))) {
    detected.push('claude');
  }
  if (existsSync(join(cwd, '.qoder'))) {
    detected.push('qoder');
  }
  if (existsSync(join(cwd, '.cursor'))) {
    detected.push('cursor');
  }
  if (existsSync(join(cwd, '.windsurf'))) {
    detected.push('windsurf');
  }
  if (existsSync(join(cwd, '.github'))) {
    detected.push('copilot');
  }
  if (existsSync(join(cwd, '.kiro'))) {
    detected.push('kiro');
  }
  if (existsSync(join(cwd, '.roo'))) {
    detected.push('roocode');
  }
  if (existsSync(join(cwd, '.gemini'))) {
    detected.push('gemini');
  }
  if (existsSync(join(cwd, '.trae'))) {
    detected.push('trae');
  }
  if (existsSync(join(cwd, '.opencode'))) {
    detected.push('opencode');
  }
  if (existsSync(join(cwd, '.continue'))) {
    detected.push('continue');
  }

  // Auto-detect based on environment variables or common patterns
  const claudeCode = process.env.CLAUDE_CODE || process.env.CLAUDE_API_KEY;
  if (claudeCode && !detected.includes('claude')) {
    detected.push('claude');
  }

  // Suggest based on most likely IDE
  let suggested: AIType | null = null;
  if (detected.length > 0) {
    suggested = detected[0];
  }

  return { detected, suggested };
}

/**
 * Detect which cloud provider skill might be needed
 */
export function detectCloudProvider(): { detected: CloudProvider[]; suggested: CloudProvider | null } {
  const detected: CloudProvider[] = [];
  const cwd = process.cwd();

  // Check for skill folders
  if (existsSync(join(cwd, 'alibaba-cloud-skill'))) {
    detected.push('alibaba-cloud');
  }
  if (existsSync(join(cwd, 'aws-cloud-skill'))) {
    detected.push('aws');
  }

  // Suggest alibaba-cloud as default
  let suggested: CloudProvider | null = null;
  if (detected.includes('alibaba-cloud')) {
    suggested = 'alibaba-cloud';
  } else if (detected.includes('aws')) {
    suggested = 'aws';
  } else {
    suggested = 'alibaba-cloud'; // Default
  }

  return { detected, suggested };
}

export function getAITypeDescription(type: AIType): string {
  const descriptions: Record<AIType, string> = {
    'claude': 'Claude Code',
    'qoder': 'Qoder',
    'cursor': 'Cursor',
    'windsurf': 'Windsurf',
    'copilot': 'GitHub Copilot',
    'kiro': 'Kiro',
    'roocode': 'Roo Code',
    'gemini': 'Gemini CLI',
    'trae': 'Trae',
    'opencode': 'OpenCode',
    'continue': 'Continue',
    'all': 'All AI IDEs',
  };
  return descriptions[type];
}

export function getCloudProviderDescription(type: CloudProvider): string {
  const descriptions: Record<CloudProvider, string> = {
    'alibaba-cloud': 'Alibaba Cloud CLI',
    'aws': 'AWS CLI',
    'all': 'All Cloud Providers',
  };
  return descriptions[type];
}
