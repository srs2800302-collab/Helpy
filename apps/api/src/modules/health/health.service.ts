export interface HealthCheckResult {
  status: 'ok';
  service: string;
  timestamp: string;
}

export class HealthService {
  getHealth(): HealthCheckResult {
    return {
      status: 'ok',
      service: 'fixi-api',
      timestamp: new Date().toISOString(),
    };
  }
}
