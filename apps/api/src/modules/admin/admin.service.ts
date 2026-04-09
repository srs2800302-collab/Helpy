import { Injectable, NotFoundException } from '@nestjs/common';
import { DisputeStatus, JobStatus, MasterVerificationStatus, PaymentStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService) {}

  async getDashboard() {
    const [
      usersCount,
      mastersCount,
      jobsCount,
      openJobsCount,
      completedJobsCount,
      disputesOpenCount,
      paymentsPaidCount,
    ] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.masterProfile.count(),
      this.prisma.job.count(),
      this.prisma.job.count({ where: { status: JobStatus.open } }),
      this.prisma.job.count({ where: { status: JobStatus.completed } }),
      this.prisma.dispute.count({
        where: { status: { in: [DisputeStatus.open, DisputeStatus.in_review] } },
      }),
      this.prisma.payment.count({ where: { status: PaymentStatus.paid } }),
    ]);

    return {
      usersCount,
      mastersCount,
      jobsCount,
      openJobsCount,
      completedJobsCount,
      disputesOpenCount,
      paymentsPaidCount,
    };
  }

  async listMasters() {
    return this.prisma.masterProfile.findMany({
      include: {
        user: true,
        categories: {
          include: {
            category: true,
          },
        },
      },
      orderBy: [{ createdAt: 'desc' }],
    });
  }

  async updateMasterVerificationStatus(
    userId: string,
    status: MasterVerificationStatus,
  ) {
    const profile = await this.prisma.masterProfile.findUnique({
      where: { userId },
    });

    if (!profile) {
      throw new NotFoundException('Master profile not found');
    }

    return this.prisma.masterProfile.update({
      where: { userId },
      data: {
        verificationStatus: status,
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

  async listJobs() {
    return this.prisma.job.findMany({
      include: {
        client: true,
        category: true,
        photos: {
          orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
        },
        offers: {
          orderBy: [{ createdAt: 'desc' }],
        },
        payments: {
          orderBy: [{ createdAt: 'desc' }],
        },
      },
      orderBy: [{ createdAt: 'desc' }],
    });
  }

  async listPayments() {
    return this.prisma.payment.findMany({
      orderBy: [{ createdAt: 'desc' }],
    });
  }
}
