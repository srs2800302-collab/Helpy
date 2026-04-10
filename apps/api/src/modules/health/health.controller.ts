import { ok } from '../../common/types/api-response.type';
import { HealthService } from './health.service';

export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  getHealth() {
    return ok(this.healthService.getHealth());
  }
}
