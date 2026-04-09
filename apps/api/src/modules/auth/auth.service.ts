import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RequestOtpDto } from './dto/request-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import type { AuthResponse } from './types/auth-response.type';

@Injectable()
export class AuthService {
  constructor(private readonly prisma: PrismaService) {}

  async requestOtp(dto: RequestOtpDto) {
    void this.prisma;

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
    void this.prisma;

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
