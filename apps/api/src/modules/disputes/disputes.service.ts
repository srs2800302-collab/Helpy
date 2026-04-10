import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { DisputeStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateDisputeDto } from './dto/create-dispute.dto';
import { UpdateDisputeStatusDto } from './dto/update-dispute-status.dto';

@Injectable()
export class DisputesService {
  constructor(private readonly prisma: PrismaService) {}

  async createDispute(dto: CreateDisputeDto) {
    const job = await this.prisma.job.findUnique({
      where: { id: dto.jobId },
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }

    const allowed =
      dto.openedByUserId === job.clientUserId ||
      dto.openedByUserId === job.selectedMasterUserId;

    if (!allowed) {
      throw new BadRequestException('User is not allowed to open dispute for this job');
    }

    return this.prisma.dispute.create({
      data: {
        jobId: dto.jobId,
        openedByUserId: dto.openedByUserId,
        reason: dto.reason.trim(),
        status: DisputeStatus.open,
      },
      include: this.disputeInclude(),
    });
  }

  async updateStatus(disputeId: string, dto: UpdateDisputeStatusDto) {
    const dispute = await this.prisma.dispute.findUnique({
      where: { id: disputeId },
    });

    if (!dispute) {
      throw new NotFoundException('Dispute not found');
    }

    const resolvedAt =
      dto.status === 'resolved' || dto.status === 'rejected' ? new Date() : null;

    return this.prisma.dispute.update({
      where: { id: disputeId },
      data: {
        status: dto.status,
        resolutionNote: dto.resolutionNote,
        resolvedAt,
      },
      include: this.disputeInclude(),
    });
  }

  async getById(disputeId: string) {
    const dispute = await this.prisma.dispute.findUnique({
      where: { id: disputeId },
      include: this.disputeInclude(),
    });

    if (!dispute) {
      throw new NotFoundException('Dispute not found');
    }

    return dispute;
  }

  async listAll() {
    return this.prisma.dispute.findMany({
      include: this.disputeInclude(),
      orderBy: [{ createdAt: 'desc' }],
    });
  }

  async listAdminDisputes(status?: string) {
    return this.prisma.dispute.findMany({
      where: {
        ...(status ? { status: status as DisputeStatus } : {}),
      },
      include: this.disputeInclude(),
      orderBy: [{ createdAt: 'desc' }],
    });
  }

  private disputeInclude() {
    return {
      job: {
        select: {
          id: true,
          title: true,
          status: true,
          clientUserId: true,
          selectedMasterUserId: true,
        },
      },
      openedBy: {
        select: {
          id: true,
          phone: true,
          role: true,
        },
      },
    } as const;
  }
}
