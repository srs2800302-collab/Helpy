import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { JobStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { SendMessageDto } from './dto/send-message.dto';
import { UpdateJobStatusDto } from './dto/update-job-status.dto';

@Injectable()
export class ChatService {
  constructor(private readonly prisma: PrismaService) {}

  async listMessages(jobId: string, viewerUserId: string) {
    const job = await this.prisma.job.findUnique({
      where: { id: jobId },
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }

    this.assertParticipantAccess(job.clientUserId, job.selectedMasterUserId, viewerUserId);

    return this.prisma.chatMessage.findMany({
      where: { jobId },
      include: {
        sender: {
          select: {
            id: true,
            phone: true,
            role: true,
          },
        },
      },
      orderBy: [{ createdAt: 'asc' }],
    });
  }

  async sendMessage(dto: SendMessageDto) {
    const job = await this.prisma.job.findUnique({
      where: { id: dto.jobId },
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }

    if (![JobStatus.master_selected, JobStatus.in_progress, JobStatus.completed].includes(job.status)) {
      throw new BadRequestException('Chat is available only after master selection');
    }

    this.assertParticipantAccess(job.clientUserId, job.selectedMasterUserId, dto.senderUserId);

    return this.prisma.chatMessage.create({
      data: {
        jobId: dto.jobId,
        senderUserId: dto.senderUserId,
        text: dto.text.trim(),
      },
      include: {
        sender: {
          select: {
            id: true,
            phone: true,
            role: true,
          },
        },
      },
    });
  }

  async updateJobStatus(jobId: string, dto: UpdateJobStatusDto) {
    const job = await this.prisma.job.findUnique({
      where: { id: jobId },
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }

    this.assertParticipantAccess(job.clientUserId, job.selectedMasterUserId, dto.actorUserId);

    if (dto.status === 'in_progress') {
      if (job.status !== JobStatus.master_selected) {
        throw new BadRequestException('Job can move to in_progress only from master_selected');
      }

      const updated = await this.prisma.job.update({
        where: { id: jobId },
        data: {
          status: JobStatus.in_progress,
        },
        include: this.jobInclude(),
      });

      return updated;
    }

    if (dto.status === 'completed') {
      if (job.status !== JobStatus.in_progress) {
        throw new BadRequestException('Job can move to completed only from in_progress');
      }

      const updated = await this.prisma.job.update({
        where: { id: jobId },
        data: {
          status: JobStatus.completed,
          completedAt: new Date(),
        },
        include: this.jobInclude(),
      });

      return updated;
    }

    throw new BadRequestException('Unsupported status transition');
  }

  private assertParticipantAccess(
    clientUserId: string,
    selectedMasterUserId: string | null,
    actorUserId: string,
  ) {
    const allowed = actorUserId === clientUserId || actorUserId === selectedMasterUserId;

    if (!allowed) {
      throw new BadRequestException('User is not a participant of this job chat');
    }
  }

  private jobInclude() {
    return {
      client: {
        select: {
          id: true,
          phone: true,
          role: true,
        },
      },
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
    } as const;
  }
}
