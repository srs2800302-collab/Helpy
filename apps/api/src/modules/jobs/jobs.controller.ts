import { Body, Controller, Get, Param, Patch, Post, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { ok } from '../../common/types/api-response.type';
import { CreateJobDto } from './dto/create-job.dto';
import { ListClientJobsQueryDto } from './dto/list-client-jobs-query.dto';
import { ListOpenJobsQueryDto } from './dto/list-open-jobs-query.dto';
import { UpdateJobDto } from './dto/update-job.dto';
import { JobsService } from './jobs.service';

@ApiTags('jobs')
@Controller('jobs')
export class JobsController {
  constructor(private readonly jobsService: JobsService) {}

  @Post()
  async createDraft(@Body() dto: CreateJobDto) {
    const job = await this.jobsService.createDraft(dto);
    return ok(job);
  }

  @Patch(':jobId')
  async updateDraft(@Param('jobId') jobId: string, @Body() dto: UpdateJobDto) {
    const job = await this.jobsService.updateDraft(jobId, dto);
    return ok(job);
  }

  @Post(':jobId/submit')
  async submitForPayment(@Param('jobId') jobId: string) {
    const job = await this.jobsService.submitForPayment(jobId);
    return ok(job);
  }

  @Get(':jobId')
  async getById(@Param('jobId') jobId: string) {
    const job = await this.jobsService.getById(jobId);
    return ok(job);
  }

  @Get()
  async listClientJobs(@Query() query: ListClientJobsQueryDto) {
    const jobs = await this.jobsService.listClientJobs(query);
    return ok(jobs);
  }

  @Get('marketplace/open')
  async listOpenJobs(@Query() query: ListOpenJobsQueryDto) {
    const jobs = await this.jobsService.listOpenJobs(query);
    return ok(jobs);
  }
}
