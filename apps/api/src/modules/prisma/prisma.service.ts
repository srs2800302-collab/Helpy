import { PrismaClient } from '@prisma/client';

export class PrismaService extends PrismaClient {
  async connectSafe(): Promise<void> {
    return Promise.resolve();
  }

  async disconnectSafe(): Promise<void> {
    return Promise.resolve();
  }
}
