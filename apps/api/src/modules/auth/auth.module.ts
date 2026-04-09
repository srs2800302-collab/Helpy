import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

export class AuthModule {
  controller = new AuthController(new AuthService());
}
