import { Injectable } from '@nestjs/common';
import { UserRole } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async findByPhone(phone: string) {
    return this.prisma.user.findUnique({
      where: { phone },
    });
  }

  async findById(id: string) {
    return this.prisma.user.findUnique({
      where: { id },
      include: {
        clientProfile: true,
        masterProfile: true,
      },
    });
  }

  async createUserByPhone(phone: string) {
    return this.prisma.user.create({
      data: {
        phone,
        isPhoneVerified: true,
      },
    });
  }

  async setRole(userId: string, role: UserRole) {
    const user = await this.prisma.user.update({
      where: { id: userId },
      data: { role },
    });

    if (role === UserRole.client) {
      await this.prisma.clientProfile.upsert({
        where: { userId },
        update: {},
        create: { userId },
      });
    }

    if (role === UserRole.master) {
      await this.prisma.masterProfile.upsert({
        where: { userId },
        update: {},
        create: { userId },
      });
    }

    return user;
  }
}
