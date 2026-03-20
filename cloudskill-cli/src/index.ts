#!/usr/bin/env node

import { Command } from 'commander';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { initCommand } from './commands/init.js';
import { versionsCommand } from './commands/versions.js';
import { updateCommand } from './commands/update.js';
import type { CloudProvider, AIType } from './types/index.js';
import { CLOUD_PROVIDERS, AI_TYPES } from './types/index.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const pkg = JSON.parse(readFileSync(join(__dirname, '../package.json'), 'utf-8'));

const program = new Command();

program
  .name('cloudskill')
  .description('CLI to install cloud skills for AI coding assistants')
  .version(pkg.version);

program
  .command('init')
  .description('Install cloud skills to AI IDE')
  .option('-p, --provider <type>', `Cloud provider (${CLOUD_PROVIDERS.join(', ')})`, 'alibaba-cloud')
  .option('-a, --ai <type>', `AI IDE type (${AI_TYPES.join(', ')})`)
  .option('-g, --global', 'Install to global home directory (~/.qoder/skills)')
  .option('--path <dir>', 'Install to specified project directory')
  .option('-f, --force', 'Overwrite existing files')
  .option('-o, --offline', 'Use local source only (skip GitHub download)')
  .action(async (options) => {
    if (options.provider && !CLOUD_PROVIDERS.includes(options.provider)) {
      console.error(`Invalid cloud provider: ${options.provider}`);
      console.error(`Valid providers: ${CLOUD_PROVIDERS.join(', ')}`);
      process.exit(1);
    }
    if (options.ai && !AI_TYPES.includes(options.ai)) {
      console.error(`Invalid AI type: ${options.ai}`);
      console.error(`Valid types: ${AI_TYPES.join(', ')}`);
      process.exit(1);
    }
    if (options.global && options.path) {
      console.error('Cannot use --global and --path together');
      process.exit(1);
    }
    await initCommand({
      provider: options.provider as CloudProvider,
      ai: options.ai as AIType | undefined,
      global: options.global,
      path: options.path,
      force: options.force,
      offline: options.offline,
    });
  });

program
  .command('versions')
  .description('List available versions')
  .action(versionsCommand);

program
  .command('update')
  .description('Update cloud skills to latest version')
  .option('-p, --provider <type>', `Cloud provider (${CLOUD_PROVIDERS.join(', ')})`, 'alibaba-cloud')
  .option('-a, --ai <type>', `AI IDE type (${AI_TYPES.join(', ')})`)
  .action(async (options) => {
    if (options.provider && !CLOUD_PROVIDERS.includes(options.provider)) {
      console.error(`Invalid cloud provider: ${options.provider}`);
      console.error(`Valid providers: ${CLOUD_PROVIDERS.join(', ')}`);
      process.exit(1);
    }
    if (options.ai && !AI_TYPES.includes(options.ai)) {
      console.error(`Invalid AI type: ${options.ai}`);
      console.error(`Valid types: ${AI_TYPES.join(', ')}`);
      process.exit(1);
    }
    await updateCommand({
      provider: options.provider as CloudProvider,
      ai: options.ai as AIType | undefined,
    });
  });

program.parse();
