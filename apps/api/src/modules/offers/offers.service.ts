import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { JobOfferStatus, JobStatus } from '@prisma/client';
import { buildOfferInclude } from '../../common/types/job-includes';
import { PrismaService } from '../prisma/prisma.service';
import { CreateOfferDto } from './dto/create-offer.dto';

@Injectable()
export class OffersService {
  constructor(private readonly prisma: PrismaService) {}

  async createOffer(dto: CreateOfferDto) {
    const job = await this.prisma.job.findUnique({
      where: { id: dto.jobId },
      include: {
        category: true,
      },
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }

    if (job.status !== JobStatus.open) {
      throw new BadRequestException('Offers can be created only for open jobs');
    }

    const master = await this.prisma.user.findUnique({
      where: { id: dto.masterUserId },
    });

    if (!master) {
      throw new NotFoundException('Master user not found');
    }

    const masterProfile = await this.prisma.masterProfile.findUnique({
      where: { userId: dto.masterUserId },
      include: {
        categories: true,
      },
    });

    if (!masterProfile) {
      throw new NotFoundException('Master profile not found');
    }

    if (!masterProfile.isAvailable) {
      throw new BadRequestException('Master is not available');
    }

    const categoryIds = masterProfile.categories.map((item) => item.categoryId);
    if (!categoryIds.includes(job.categoryId)) {
      throw new BadRequestException('Master does not support this category');
    }

    const existing = await this.prisma.jobOffer.findUnique({
      where: {
        jobId_masterUserId: {
          jobId: dto.jobId,
          masterUserId: dto.masterUserId,
        },
      },
    });

    if (existing && existing.status === JobOfferStatus.active) {
      throw new BadRequestException('Active offer already exists for this job');
    }

    if (existing) {
      return this.prisma.jobOffer.update({
        where: { id: existing.id },
        data: {
          message: dto.message,
          priceComment: dto.priceComment,
          status: JobOfferStatus.active,
        },
        include: buildOfferInclude(),
      });
    }

    return this.prisma.jobOffer.create({
      data: {
        jobId: dto.jobId,
        masterUserId: dto.masterUserId,
        message: dto.message,
        priceComment: dto.priceComment,
        status: JobOfferStatus.active,
      },
      include: buildOfferInclude(),
    });
  }

  async withdrawOffer(offerId: string, masterUserId: string) {
    const offer = await this.prisma.jobOffer.findUnique({
      where: { id: offerId },
    });

    if (!offer) {
      throw new NotFoundException('Offer not found');
    }

    if (offer.masterUserId !== masterUserId) {
      throw new BadRequestException('Offer does not belong to this master');
    }

    if (offer.status !== JobOfferStatus.active) {
      throw new BadRequestException('Only active offers can be withdrawn');
    }

    return this.prisma.jobOffer.update({
      where: { id: offerId },
      data: {
        status: JobOfferStatus.withdrawn,
      },
      include: buildOfferInclude(),
    });
  }

  async listJobOffers(jobId: string, clientUserId?: string) {
    const job = await this.prisma.job.findUnique({
      where: { id: jobId },
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }

    if (clientUserId && job.clientUserId !== clientUserId) {
      throw new BadRequestException('Job does not belong to this client');
    }

    return this.prisma.jobOffer.findMany({
      where: { jobId },
      include: buildOfferInclude(),
      orderBy: [{ createdAt: 'desc' }],
    });
  }

  async selectOffer(offerId: string, clientUserId: string) {
    const offer = await this.prisma.jobOffer.findUnique({
      where: { id: offerId },
      include: {
        job: true,
      },
    });

    if (!offer) {
      throw new NotFoundException('Offer not found');
    }

    if (offer.job.clientUserId !== clientUserId) {
      throw new BadRequestException('Job does not belong to this client');
    }

    if (offer.job.status !== JobStatus.open) {
      throw new BadRequestException('Master can be selected only for open job');
    }

    if (offer.status !== JobOfferStatus.active) {
      throw new BadRequestException('Only active offer can be selected');
    }

    await this.prisma.$transaction([
      this.prisma.jobOffer.update({
        where: { id: offer.id },
        data: {
          status: JobOfferStatus.accepted,
        },
      }),
      this.prisma.jobOffer.updateMany({
        where: {
          jobId: offer.jobId,
          id: { not: offer.id },
          status: JobOfferStatus.active,
        },
        data: {
          status: JobOfferStatus.rejected,
        },
      }),
      this.prisma.job.update({
        where: { id: offer.jobId },
        data: {
          status: JobStatus.master_selected,
          selectedOfferId: offer.id,
          selectedMasterUserId: offer.masterUserId,
        },
      }),
    ]);

    return this.getOfferById(offer.id);
  }

  async getOfferById(offerId: string) {
    const offer = await this.prisma.jobOffer.findUnique({
      where: { id: offerId },
      include: buildOfferInclude(),
    });

    if (!offer) {
      throw new NotFoundException('Offer not found');
    }

    return offer;
  }

  async listMasterOffers(masterUserId: string) {
    return this.prisma.jobOffer.findMany({
      where: { masterUserId },
      include: buildOfferInclude(),
      orderBy: [{ createdAt: 'desc' }],
    });
  }
}
