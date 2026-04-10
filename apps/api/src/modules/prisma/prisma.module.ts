import { PrismaService } from './prisma.service';

export class PrismaModule {
  prisma = new PrismaService();
}
