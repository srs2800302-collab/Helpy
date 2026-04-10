import { Body, Controller, Get, Param, Patch, Post, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { ok } from '../../common/types/api-response.type';
import { CreateOfferDto } from './dto/create-offer.dto';
import { ListJobOffersQueryDto } from './dto/list-job-offers-query.dto';
import { SelectOfferDto } from './dto/select-offer.dto';
import { OffersService } from './offers.service';

@ApiTags('offers')
@Controller('offers')
export class OffersController {
  constructor(private readonly offersService: OffersService) {}

  @Post()
  async createOffer(@Body() dto: CreateOfferDto) {
    const offer = await this.offersService.createOffer(dto);
    return ok(offer);
  }

  @Patch(':offerId/withdraw/:masterUserId')
  async withdrawOffer(
    @Param('offerId') offerId: string,
    @Param('masterUserId') masterUserId: string,
  ) {
    const offer = await this.offersService.withdrawOffer(offerId, masterUserId);
    return ok(offer);
  }

  @Get('job/:jobId')
  async listJobOffers(
    @Param('jobId') jobId: string,
    @Query() query: ListJobOffersQueryDto,
  ) {
    const offers = await this.offersService.listJobOffers(jobId, query.clientUserId);
    return ok(offers);
  }

  @Patch(':offerId/select')
  async selectOffer(@Param('offerId') offerId: string, @Body() dto: SelectOfferDto) {
    const offer = await this.offersService.selectOffer(offerId, dto.clientUserId);
    return ok(offer);
  }

  @Get('master/:masterUserId')
  async listMasterOffers(@Param('masterUserId') masterUserId: string) {
    const offers = await this.offersService.listMasterOffers(masterUserId);
    return ok(offers);
  }

  @Get(':offerId')
  async getOfferById(@Param('offerId') offerId: string) {
    const offer = await this.offersService.getOfferById(offerId);
    return ok(offer);
  }
}
