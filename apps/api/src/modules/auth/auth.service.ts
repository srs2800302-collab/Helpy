import {
  BadRequestException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { OtpSessionStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { OTP_EXPIRES_IN_SECONDS, OTP_MAX_ATTEMPTS } from './constants/auth.constants';
import { RequestOtpDto } from './dto/request-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import type { AuthResponse, RequestOtpResult } from './types/auth-response.type';
import { generateOtpCode } from './utils/otp.util';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
  ) {}

  async requestOtp(dto: RequestOtpDto): Promise<{ success: true; data: RequestOtpResult }> {
    const phone = dto.phone.trim();
    const code = generateOtpCode();
    const expiresAt = new Date(Date.now() + OTP_EXPIRES_IN_SECONDS * 1000);

    await this.prisma.otpSession.updateMany({
      where: {
        phone,
        status: OtpSessionStatus.pending,
      },
      data: {
        status: OtpSessionStatus.cancelled,
      },
    });

    await this.prisma.otpSession.create({
      data: {
        phone,
        code,
        expiresAt,
        status: OtpSessionStatus.pending,
      },
    });

    return {
      success: true,
      data: {
        sent: true,
        expiresInSeconds: OTP_EXPIRES_IN_SECONDS,
        debugCode: code,
      },
    };
  }

  async verifyOtp(dto: VerifyOtpDto): Promise<{ success: true; data: AuthResponse }> {
    const phone = dto.phone.trim();
    const code = dto.code.trim();

    const session = await this.prisma.otpSession.findFirst({
      where: {
        phone,
        status: OtpSessionStatus.pending,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    if (!session) {
      throw new NotFoundException('OTP session not found');
    }

    if (session.expiresAt.getTime() < Date.now()) {
      await this.prisma.otpSession.update({
        where: { id: session.id },
        data: { status: OtpSessionStatus.expired },
      });

      throw new UnauthorizedException('OTP expired');
    }

    if (session.attemptsCount >= OTP_MAX_ATTEMPTS) {
      await this.prisma.otpSession.update({
        where: { id: session.id },
        data: { status: OtpSessionStatus.cancelled },
      });

      throw new UnauthorizedException('OTP attempts exceeded');
    }

    if (session.code !== code) {
      await this.prisma.otpSession.update({
        where: { id: session.id },
        data: {
          attemptsCount: {
            increment: 1,
          },
        },
      });

      throw new BadRequestException('Invalid OTP code');
    }

    let user = await this.usersService.findByPhone(phone);
    const isNewUser = !user;

    if (!user) {
      user = await this.usersService.createUserByPhone(phone);
    }

    await this.prisma.otpSession.update({
      where: { id: session.id },
      data: {
        status: OtpSessionStatus.verified,
        verifiedAt: new Date(),
        userId: user.id,
      },
    });

    return {
      success: true,
      data: {
        user: {
          id: user.id,
          phone: user.phone,
          role: user.role,
          isActive: user.isActive,
          isPhoneVerified: true,
          createdAt: user.createdAt.toISOString(),
        },
        tokens: {
          accessToken: `stub-access-${user.id}`,
          refreshToken: `stub-refresh-${user.id}`,
        },
        isNewUser,
        needsRoleSelection: !user.role,
      },
    };
  }
}
