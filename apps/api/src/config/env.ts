export interface AppConfig {
  nodeEnv: string;
  port: number;
  appName: string;
  apiPrefix: string;
  databaseUrl: string;
  jwtAccessSecret: string;
  jwtRefreshSecret: string;
}

function readEnv(name: string, fallback = ''): string {
  const value = process.env[name];
  if (typeof value === 'string' && value.length > 0) {
    return value;
  }
  return fallback;
}

function readNumber(name: string, fallback: number): number {
  const raw = process.env[name];
  if (!raw) {
    return fallback;
  }

  const parsed = Number(raw);
  return Number.isFinite(parsed) ? parsed : fallback;
}

export function getAppConfig(): AppConfig {
  return {
    nodeEnv: readEnv('NODE_ENV', 'development'),
    port: readNumber('PORT', 3000),
    appName: readEnv('APP_NAME', 'fixi-api'),
    apiPrefix: readEnv('API_PREFIX', 'api/v1'),
    databaseUrl: readEnv('DATABASE_URL'),
    jwtAccessSecret: readEnv('JWT_ACCESS_SECRET'),
    jwtRefreshSecret: readEnv('JWT_REFRESH_SECRET'),
  };
}
