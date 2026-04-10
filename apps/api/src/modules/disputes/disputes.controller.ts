import { Body, Controller, Get, Param, Patch, Post } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { ok } from '../../common/types/api-response.type';
import { CreateDisputeDto } from './dto/create-dispute.dto';
import { UpdateDisputeStatusDto } from './dto/update-dispute-status.dto';
import { DisputesService } from './disputes.service';

@ApiTags('disputes')
@Controller('disputes')
export class DisputesController {
  constructor(private readonly disputesService: DisputesService) {}

  @Post()
  async createDispute(@Body() dto: CreateDisputeDto) {
    const dispute = await this.disputesService.createDispute(dto);
    return ok(dispute);
  }

  @Patch(':disputeId/status')
  async updateStatus(
    @Param('disputeId') disputeId: string,
    @Body() dto: UpdateDisputeStatusDto,
  ) {
    const dispute = await this.disputesService.updateStatus(disputeId, dto);
    return ok(dispute);
  }

  @Get(':disputeId')
  async getById(@Param('disputeId') disputeId: string) {
    const dispute = await this.disputesService.getById(disputeId);
    return ok(dispute);
  }

  @Get()
  async listAll() {
    const disputes = await this.disputesService.listAll();
    return ok(disputes);
  }
}
