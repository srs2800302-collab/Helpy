import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AttachJobPhotoDto } from './dto/attach-job-photo.dto';
import { ReorderJobPhotosDto } from './dto/reorder-job-photos.dto';

@Injectable()
export class UploadsService {
  constructor(private readonly prisma: PrismaService) {}

  async attachJobPhoto(dto: AttachJobPhotoDto) {
    const job = await this.prisma.job.findUnique({
      where: { id: dto.jobId },
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }

    let sortOrder = dto.sortOrder;

    if (sortOrder === undefined) {
      const lastPhoto = await this.prisma.jobPhoto.findFirst({
        where: { jobId: dto.jobId },
        orderBy: [{ sortOrder: 'desc' }, { createdAt: 'desc' }],
      });

      sortOrder = lastPhoto ? lastPhoto.sortOrder + 1 : 0;
    }

    const photo = await this.prisma.jobPhoto.create({
      data: {
        jobId: dto.jobId,
        url: dto.url,
        sortOrder,
      },
    });

    return photo;
  }

  async listJobPhotos(jobId: string) {
    const job = await this.prisma.job.findUnique({
      where: { id: jobId },
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }

    return this.prisma.jobPhoto.findMany({
      where: { jobId },
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
    });
  }

  async deleteJobPhoto(photoId: string) {
    const photo = await this.prisma.jobPhoto.findUnique({
      where: { id: photoId },
    });

    if (!photo) {
      throw new NotFoundException('Job photo not found');
    }

    await this.prisma.jobPhoto.delete({
      where: { id: photoId },
    });

    return {
      deleted: true,
      photoId,
      jobId: photo.jobId,
    };
  }

  async reorderJobPhotos(jobId: string, dto: ReorderJobPhotosDto) {
    const job = await this.prisma.job.findUnique({
      where: { id: jobId },
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }

    const existingPhotos = await this.prisma.jobPhoto.findMany({
      where: { jobId },
    });

    const existingIds = new Set(existingPhotos.map((item) => item.id));

    for (const item of dto.items) {
      if (!existingIds.has(item.photoId)) {
        throw new BadRequestException(`Photo does not belong to job: ${item.photoId}`);
      }
    }

    await this.prisma.$transaction(
      dto.items.map((item) =>
        this.prisma.jobPhoto.update({
          where: { id: item.photoId },
          data: { sortOrder: item.sortOrder },
        }),
      ),
    );

    return this.listJobPhotos(jobId);
  }

  getPresignUploadStub(fileName: string) {
    const safeFileName = fileName.replace(/[^a-zA-Z0-9._-]/g, '_');

    return {
      method: 'PUT',
      uploadUrl: `https://example-upload.local/${safeFileName}`,
      publicUrl: `https://cdn.example.local/${safeFileName}`,
      expiresInSeconds: 900,
    };
  }
}
