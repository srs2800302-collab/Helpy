import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

const MVP_CATEGORIES = [
  'cleaning',
  'handyman',
  'plumbing',
  'electrical',
  'locks',
  'aircon',
  'furniture_assembly',
] as const;

@Injectable()
export class CategoriesService {
  constructor(private readonly prisma: PrismaService) {}

  async listActive() {
    return this.prisma.serviceCategory.findMany({
      where: { isActive: true },
      orderBy: [{ sortOrder: 'asc' }, { slug: 'asc' }],
    });
  }

  async seedMvpCategories() {
    for (const [index, slug] of MVP_CATEGORIES.entries()) {
      await this.prisma.serviceCategory.upsert({
        where: { slug },
        update: {
          isActive: true,
          sortOrder: index,
        },
        create: {
          slug,
          isActive: true,
          sortOrder: index,
        },
      });
    }

    return this.listActive();
  }

  async findBySlugs(slugs: string[]) {
    return this.prisma.serviceCategory.findMany({
      where: {
        slug: {
          in: slugs,
        },
      },
      orderBy: [{ sortOrder: 'asc' }, { slug: 'asc' }],
    });
  }
}
