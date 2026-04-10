import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { JobStatus, PaymentStatus, PaymentType, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateDepositDto } from './dto/create-deposit.dto';
import { CreateRefundDto } from './dto/create-refund.dto';
import { MarkPaymentPaidDto } from './dto/mark-payment-paid.dto';

@Injectable()
export class PaymentsService {
  constructor(private readonly prisma: PrismaService) {}

  async createDeposit(dto: CreateDepositDto) {
    const job = await this.prisma.job.findUnique({
      where: { id: dto.jobId },
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }

    if (job.clientUserId !== dto.userId) {
      throw new BadRequestException('Only job owner can create deposit');
    }

    if (job.status !== JobStatus.awaiting_payment) {
      throw new BadRequestException('Deposit can be created only for awaiting_payment job');
    }

    const existingDeposit = await this.prisma.payment.findFirst({
      where: {
        jobId: dto.jobId,
        type: PaymentType.deposit,
        status: {
          in: [PaymentStatus.pending, PaymentStatus.paid],
        },
      },
      orderBy: [{ createdAt: 'desc' }],
    });

    if (existingDeposit) {
      return existingDeposit;
    }

    const user = await this.prisma.user.findUnique({
      where: { id: dto.userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return this.prisma.payment.create({
      data: {
        jobId: dto.jobId,
        userId: dto.userId,
        type: PaymentType.deposit,
        status: PaymentStatus.pending,
        amount: new Prisma.Decimal(dto.amount),
        currency: dto.currency ?? 'THB',
        provider: dto.provider,
        providerRef: dto.providerRef,
      },
    });
  }

  async markPaid(paymentId: string, dto: MarkPaymentPaidDto) {
    const payment = await this.prisma.payment.findUnique({
      where: { id: paymentId },
    });

    if (!payment) {
      throw new NotFoundException('Payment not found');
    }

    if (payment.status !== PaymentStatus.pending) {
      throw new BadRequestException('Only pending payments can be marked as paid');
    }

    const updatedPayment = await this.prisma.payment.update({
      where: { id: paymentId },
      data: {
        status: PaymentStatus.paid,
        paidAt: new Date(),
        ...(dto.provider !== undefined ? { provider: dto.provider } : {}),
        ...(dto.providerRef !== undefined ? { providerRef: dto.providerRef } : {}),
      },
    });

    const job = await this.prisma.job.findUnique({
      where: { id: payment.jobId },
    });

    if (
      job &&
      job.status === JobStatus.awaiting_payment &&
      payment.type === PaymentType.deposit
    ) {
      await this.prisma.job.update({
        where: { id: job.id },
        data: {
          status: JobStatus.open,
        },
      });
    }

    return this.getById(updatedPayment.id);
  }

  async createRefund(dto: CreateRefundDto) {
    const job = await this.prisma.job.findUnique({
      where: { id: dto.jobId },
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: dto.userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return this.prisma.payment.create({
      data: {
        jobId: dto.jobId,
        userId: dto.userId,
        type: PaymentType.refund,
        status: PaymentStatus.refunded,
        amount: new Prisma.Decimal(dto.amount),
        currency: dto.currency ?? 'THB',
        provider: dto.provider,
        providerRef: dto.providerRef,
        refundedAt: new Date(),
      },
    });
  }

  async getById(paymentId: string) {
    const payment = await this.prisma.payment.findUnique({
      where: { id: paymentId },
    });

    if (!payment) {
      throw new NotFoundException('Payment not found');
    }

    return payment;
  }

  async getDepositByJob(jobId: string) {
    const job = await this.prisma.job.findUnique({
      where: { id: jobId },
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }

    const payment = await this.prisma.payment.findFirst({
      where: {
        jobId,
        type: PaymentType.deposit,
      },
      orderBy: [{ createdAt: 'desc' }],
    });

    if (!payment) {
      throw new NotFoundException('Deposit payment not found');
    }

    return payment;
  }

  async listByJob(jobId: string) {
    const job = await this.prisma.job.findUnique({
      where: { id: jobId },
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }

    return this.prisma.payment.findMany({
      where: { jobId },
      orderBy: [{ createdAt: 'desc' }],
    });
  }

  async listAdminPayments(status?: string) {
    return this.prisma.payment.findMany({
      where: {
        ...(status ? { status: status as PaymentStatus } : {}),
      },
      orderBy: [{ createdAt: 'desc' }],
    });
  }
}
