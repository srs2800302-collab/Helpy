import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { JobStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateReviewDto } from './dto/create-review.dto';

@Injectable()
export class ReviewsService {
  constructor(private readonly prisma: PrismaService) {}

  async createReview(dto: CreateReviewDto) {
    const job = await this.prisma.job.findUnique({
      where: { id: dto.jobId },
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }

    if (job.clientUserId !== dto.clientUserId) {
      throw new BadRequestException('Job does not belong to this client');
    }

    if (job.status !== JobStatus.completed) {
      throw new BadRequestException('Review can be created only for completed job');
    }

    if (!job.selectedMasterUserId) {
      throw new BadRequestException('Job has no selected master');
    }

    const existing = await this.prisma.review.findUnique({
      where: { jobId: dto.jobId },
    });

    if (existing) {
      throw new BadRequestException('Review already exists for this job');
    }

    return this.prisma.review.create({
      data: {
        jobId: dto.jobId,
        clientUserId: dto.clientUserId,
        masterUserId: job.selectedMasterUserId,
        rating: dto.rating,
        comment: dto.comment?.trim(),
      },
      include: this.reviewInclude(),
    });
  }

  async getJobReview(jobId: string) {
    const review = await this.prisma.review.findUnique({
      where: { jobId },
      include: this.reviewInclude(),
    });

    if (!review) {
      throw new NotFoundException('Review not found');
    }

    return review;
  }

  async listMasterReviews(masterUserId: string) {
    return this.prisma.review.findMany({
      where: { masterUserId },
      include: this.reviewInclude(),
      orderBy: [{ createdAt: 'desc' }],
    });
  }

  async getMasterReviewsSummary(masterUserId: string) {
    const [reviewsCount, aggregate] = await Promise.all([
      this.prisma.review.count({
        where: { masterUserId },
      }),
      this.prisma.review.aggregate({
        where: { masterUserId },
        _avg: {
          rating: true,
        },
      }),
    ]);

    return {
      masterUserId,
      reviewsCount,
      avgRating: aggregate._avg.rating ?? null,
    };
  }

  private reviewInclude() {
    return {
      job: {
        select: {
          id: true,
          title: true,
          status: true,
          category: true,
        },
      },
      client: {
        select: {
          id: true,
          phone: true,
          role: true,
          clientProfile: true,
        },
      },
      master: {
        select: {
          id: true,
          phone: true,
          role: true,
          masterProfile: true,
        },
      },
    } as const;
  }
}
