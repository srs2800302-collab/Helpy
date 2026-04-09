import type { RequestOtpDto } from './dto/request-otp.dto';
import type { VerifyOtpDto } from './dto/verify-otp.dto';
import type { AuthResponse } from './types/auth-response.type';

export class AuthService {
  async requestOtp(dto: RequestOtpDto) {
    return {
      success: true,
      data: {
        sent: true,
        expiresInSeconds: 300,
        phone: dto.phone,
      },
    };
  }

  async verifyOtp(dto: VerifyOtpDto): Promise<{ success: true; data: AuthResponse }> {
    return {
      success: true,
      data: {
        user: {
          id: 'stub-user-id',
          phone: dto.phone,
          role: null,
          isActive: true,
          isPhoneVerified: true,
          createdAt: new Date().toISOString(),
        },
        tokens: {
          accessToken: 'stub-access-token',
          refreshToken: 'stub-refresh-token',
        },
        isNewUser: true,
        needsRoleSelection: true,
      },
    };
  }
}
