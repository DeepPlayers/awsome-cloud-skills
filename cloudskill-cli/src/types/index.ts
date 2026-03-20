export type CloudProvider = 'alibaba-cloud' | 'aws' | 'all';

export type AIType = 'claude' | 'qoder' | 'cursor' | 'windsurf' | 'copilot' | 'kiro' | 'roocode' | 'gemini' | 'trae' | 'opencode' | 'continue' | 'all';

export type InstallType = 'full' | 'reference';

export interface Release {
  tag_name: string;
  name: string;
  published_at: string;
  html_url: string;
  assets: Asset[];
}

export interface Asset {
  name: string;
  browser_download_url: string;
  size: number;
}

export interface InstallConfig {
  provider: CloudProvider;
  ai: AIType;
  version?: string;
  force?: boolean;
}

export interface SkillConfig {
  skill: string;
  displayName: string;
  installType: InstallType;
  folderStructure: {
    root: string;
    skillPath: string;
    filename: string;
  };
  scriptPath: string;
  frontmatter: Record<string, string> | null;
  sections: {
    quickReference: boolean;
  };
  title: string;
  description: string;
}

export const CLOUD_PROVIDERS: CloudProvider[] = ['alibaba-cloud', 'aws', 'all'];

export const AI_TYPES: AIType[] = ['claude', 'qoder', 'cursor', 'windsurf', 'copilot', 'kiro', 'roocode', 'gemini', 'trae', 'opencode', 'continue', 'all'];

// AI IDE folder mapping
export const AI_FOLDERS: Record<Exclude<AIType, 'all'>, string[]> = {
  claude: ['.claude'],
  qoder: ['.qoder'],
  cursor: ['.cursor', '.shared'],
  windsurf: ['.windsurf', '.shared'],
  copilot: ['.github', '.shared'],
  kiro: ['.kiro'],
  roocode: ['.roo', '.shared'],
  gemini: ['.gemini', '.shared'],
  trae: ['.trae', '.shared'],
  opencode: ['.opencode', '.shared'],
  continue: ['.continue'],
};

// Cloud provider folder mapping
export const CLOUD_FOLDERS: Record<Exclude<CloudProvider, 'all'>, string[]> = {
  'alibaba-cloud': ['alibaba-cloud-skill'],
  'aws': ['aws-cloud-skill'],
};
