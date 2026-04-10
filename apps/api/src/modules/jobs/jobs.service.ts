import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { JobStatus, Prisma } from '@prisma/client';
import { buildJobInclude } from '../../common/types/job-includes';
import { PrismaService } from '../prisma/prisma.service';
import { CreateJobDto } from './dto/create-job.dto';
import { ListClientJobsQueryDto } from './dto/list-client-jobs-query.dto';
import { ListOpenJobsQueryDto } from './dto/list-open-jobs-query.dto';
import { UpdateJobDto } from './dto/update-job.dto';

@Injectable()
export class JobsService {
  constructor(private readonly prisma: PrismaService) {}

  async createDraft(dto: CreateJobDto) {
    const client = await this.prisma.user.findUnique({
      where: { id: dto.clientUserId },
    });

    if (!client) {
      throw new NotFoundException('Client user not found');
    }

    const category = await this.prisma.serviceCategory.findUnique({
      where: { id: dto.categoryId },
    });

    if (!category) {
      throw new NotFoundException('Category not found');
    }

    return this.prisma.job.create({
      data: {
        clientUserId: dto.clientUserId,
        categoryId: dto.categoryId,
        title: dto.title,
        description: dto.description,
        addressText: dto.addressText,
        locationLat:
          dto.locationLat !== undefined ? new Prisma.Decimal(dto.locationLat) : undefined,
        locationLng:
          dto.locationLng !== undefined ? new Prisma.Decimal(dto.locationLng) : undefined,
        status: JobStatus.draft,
      },
      include: buildJobInclude(),
    });
  }

  async updateDraft(jobId: string, dto: UpdateJobDto) {
    const job = await this.prisma.job.findUnique({
      where: { id: jobId },
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }

    if (job.status !== JobStatus.draft) {
      throw new BadRequestException('Only draft jobs can be updated');
    }

    if (dto.categoryId) {
      const category = await this.prisma.serviceCategory.findUnique({
        where: { id: dto.categoryId },
      });

      if (!category) {
        throw new NotFoundException('Category not found');
      }
    }

    return this.prisma.job.update({
      where: { id: jobId },
      data: {
        ...(dto.categoryId != null ? { categoryId: dto.categoryId } : {}),
        ...(dto.title != null ? { title: dto.title } : {}),
        ...(dto.description != null ? { description: dto.description } : {}),
        ...(dto.addressText != null ? { addressText: dto.addressText } : {}),
        ...(dto.locationLat != null
          ? { locationLat: new Prisma.Decimal(dto.locationLat) }
          : {}),
        ...(dto.locationLng != null
          ? { locationLng: new Prisma.Decimal(dto.locationLng) }
          : {}),
      },
      include: buildJobInclude(),
    });
  }

  async submitForPayment(jobId: string) {
    const job = await this.prisma.job.findUnique({
      where: { id: jobId },
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }

    if (job.status !== JobStatus.draft) {
      throw new BadRequestException('Only draft jobs can be submitted for payment');
    }

    return this.prisma.job.update({
      where: { id: jobId },
      data: {
        status: JobStatus.awaiting_payment,
      },
      include: buildJobInclude(),
    });
  }

  async getById(jobId: string) {
    const job = await this.prisma.job.findUnique({
      where: { id: jobId },
      include: buildJobInclude(),
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }

    return job;
  }

  async listClientJobs(query: ListClientJobsQueryDto) {
    return this.prisma.job.findMany({
      where: {
        clientUserId: query.clientUserId,
        ...(query.status ? { status: query.status as JobStatus } : {}),
      },
      include: buildJobInclude(),
      orderBy: [{ createdAt: 'desc' }],
    });
  }

  async listOpenJobs(query: ListOpenJobsQueryDto) {
    let allowedCategoryIds: string[] | undefined;

    if (query.masterUserId) {
      const masterProfile = await this.prisma.masterProfile.findUnique({
        where: { userId: query.masterUserId },
        include: {
          categories: true,
        },
      });

      if (!masterProfile) {
        throw new NotFoundException('Master profile not found');
      }

      allowedCategoryIds = masterProfile.categories.map((item) => item.categoryId);
    }

    return this.prisma.job.findMany({
      where: {
        status: JobStatus.open,
        ...(query.categoryId ? { categoryId: query.categoryId } : {}),
        ...(allowedCategoryIds ? { categoryId: { in: allowedCategoryIds } } : {}),
      },
      include: buildJobInclude(),
      orderBy: [{ createdAt: 'desc' }],
    });
  }
}
