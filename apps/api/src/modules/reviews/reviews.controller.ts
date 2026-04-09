import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { ok } from '../../common/types/api-response.type';
import { CreateReviewDto } from './dto/create-review.dto';
import { ReviewsService } from './reviews.service';

@ApiTags('reviews')
@Controller('reviews')
export class ReviewsController {
  constructor(private readonly reviewsService: ReviewsService) {}

  @Post()
  async createReview(@Body() dto: CreateReviewDto) {
    const review = await this.reviewsService.createReview(dto);
    return ok(review);
  }

  @Get('job/:jobId')
  async getJobReview(@Param('jobId') jobId: string) {
    const review = await this.reviewsService.getJobReview(jobId);
    return ok(review);
  }

  @Get('master/:masterUserId')
  async listMasterReviews(@Param('masterUserId') masterUserId: string) {
    const reviews = await this.reviewsService.listMasterReviews(masterUserId);
    return ok(reviews);
  }

  @Get('master/:masterUserId/summary')
  async getMasterReviewsSummary(@Param('masterUserId') masterUserId: string) {
    const summary = await this.reviewsService.getMasterReviewsSummary(masterUserId);
    return ok(summary);
  }
}
