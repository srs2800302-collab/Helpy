import { AuthService } from './auth.service';
import type { RequestOtpDto } from './dto/request-otp.dto';
import type { VerifyOtpDto } from './dto/verify-otp.dto';

export class AuthController {
  constructor(private readonly authService: AuthService) {}

  requestOtp(dto: RequestOtpDto) {
    return this.authService.requestOtp(dto);
  }

  verifyOtp(dto: VerifyOtpDto) {
    return this.authService.verifyOtp(dto);
  }
}
