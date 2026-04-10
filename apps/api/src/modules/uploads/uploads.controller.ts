import { Body, Controller, Delete, Get, Param, Post, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { ok } from '../../common/types/api-response.type';
import { AttachJobPhotoDto } from './dto/attach-job-photo.dto';
import { ReorderJobPhotosDto } from './dto/reorder-job-photos.dto';
import { UploadsService } from './uploads.service';

@ApiTags('uploads')
@Controller('uploads')
export class UploadsController {
  constructor(private readonly uploadsService: UploadsService) {}

  @Post('job-photos')
  async attachJobPhoto(@Body() dto: AttachJobPhotoDto) {
    const photo = await this.uploadsService.attachJobPhoto(dto);
    return ok(photo);
  }

  @Get('job-photos/:jobId')
  async listJobPhotos(@Param('jobId') jobId: string) {
    const photos = await this.uploadsService.listJobPhotos(jobId);
    return ok(photos);
  }

  @Delete('job-photos/:photoId')
  async deleteJobPhoto(@Param('photoId') photoId: string) {
    const result = await this.uploadsService.deleteJobPhoto(photoId);
    return ok(result);
  }

  @Post('job-photos/:jobId/reorder')
  async reorderJobPhotos(
    @Param('jobId') jobId: string,
    @Body() dto: ReorderJobPhotosDto,
  ) {
    const photos = await this.uploadsService.reorderJobPhotos(jobId, dto);
    return ok(photos);
  }

  @Get('presign')
  async getPresignUploadStub(@Query('fileName') fileName: string) {
    const result = this.uploadsService.getPresignUploadStub(fileName || 'file.jpg');
    return ok(result);
  }
}
