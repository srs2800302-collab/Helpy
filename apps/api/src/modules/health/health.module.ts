import { HealthController } from './health.controller';
import { HealthService } from './health.service';

export class HealthModule {
  controller = new HealthController(new HealthService());
}
