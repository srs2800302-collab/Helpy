import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CategoriesService } from '../categories/categories.service';
import { UpdateClientProfileDto } from './dto/update-client-profile.dto';
import { UpdateMasterProfileDto } from './dto/update-master-profile.dto';

@Injectable()
export class ProfilesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly categoriesService: CategoriesService,
  ) {}

  async getClientProfile(userId: string) {
    const profile = await this.prisma.clientProfile.findUnique({
      where: { userId },
      include: { user: true },
    });

    if (!profile) {
      throw new NotFoundException('Client profile not found');
    }

    return profile;
  }

  async updateClientProfile(userId: string, dto: UpdateClientProfileDto) {
    return this.prisma.clientProfile.upsert({
      where: { userId },
      update: {
        ...dto,
      },
      create: {
        userId,
        ...dto,
      },
      include: {
        user: true,
      },
    });
  }

  async getMasterProfile(userId: string) {
    const profile = await this.prisma.masterProfile.findUnique({
      where: { userId },
      include: {
        user: true,
        categories: {
          include: {
            category: true,
          },
        },
      },
    });

    if (!profile) {
      throw new NotFoundException('Master profile not found');
    }

    return profile;
  }

  async getPublicMasterProfile(userId: string) {
    const profile = await this.prisma.masterProfile.findUnique({
      where: { userId },
      include: {
        categories: {
          include: {
            category: true,
          },
        },
      },
    });

    if (!profile) {
      throw new NotFoundException('Master profile not found');
    }

    return {
      id: profile.id,
      userId: profile.userId,
      displayName: profile.displayName,
      photoUrl: profile.photoUrl,
      bio: profile.bio,
      verificationStatus: profile.verificationStatus,
      isAvailable: profile.isAvailable,
      categories: profile.categories.map((item) => item.category),
    };
  }

  async updateMasterProfile(userId: string, dto: UpdateMasterProfileDto) {
    return this.prisma.masterProfile.upsert({
      where: { userId },
      update: {
        ...dto,
      },
      create: {
        userId,
        ...dto,
      },
      include: {
        user: true,
        categories: {
          include: {
            category: true,
          },
        },
      },
    });
  }

  async setMasterCategories(userId: string, slugs: string[]) {
    const profile = await this.prisma.masterProfile.findUnique({
      where: { userId },
    });

    if (!profile) {
      throw new NotFoundException('Master profile not found');
    }

    const categories = await this.categoriesService.findBySlugs(slugs);
    if (categories.length !== slugs.length) {
      throw new BadRequestException('Some categories do not exist');
    }

    await this.prisma.masterCategory.deleteMany({
      where: { masterProfileId: profile.id },
    });

    if (categories.length > 0) {
      await this.prisma.masterCategory.createMany({
        data: categories.map((category) => ({
          masterProfileId: profile.id,
          categoryId: category.id,
        })),
      });
    }

    return this.getMasterProfile(userId);
  }
}
