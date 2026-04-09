import { getAppConfig } from './config/env';
import { HealthModule } from './modules/health/health.module';
import { PrismaModule } from './modules/prisma/prisma.module';
import { AuthModule } from './modules/auth/auth.module';

export class AppModule {
  readonly config = getAppConfig();
  readonly prisma = new PrismaModule();
  readonly health = new HealthModule();
  readonly auth = new AuthModule();
}
