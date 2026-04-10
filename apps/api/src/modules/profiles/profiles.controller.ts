import { Body, Controller, Get, Param, Patch, Post } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { ok } from '../../common/types/api-response.type';
import { SetMasterCategoriesDto } from '../categories/dto/set-master-categories.dto';
import { UpdateClientProfileDto } from './dto/update-client-profile.dto';
import { UpdateMasterProfileDto } from './dto/update-master-profile.dto';
import { ProfilesService } from './profiles.service';

@ApiTags('profiles')
@Controller('profiles')
export class ProfilesController {
  constructor(private readonly profilesService: ProfilesService) {}

  @Get('clients/:userId')
  async getClientProfile(@Param('userId') userId: string) {
    const profile = await this.profilesService.getClientProfile(userId);
    return ok(profile);
  }

  @Patch('clients/:userId')
  async updateClientProfile(
    @Param('userId') userId: string,
    @Body() dto: UpdateClientProfileDto,
  ) {
    const profile = await this.profilesService.updateClientProfile(userId, dto);
    return ok(profile);
  }

  @Get('masters/:userId')
  async getMasterProfile(@Param('userId') userId: string) {
    const profile = await this.profilesService.getMasterProfile(userId);
    return ok(profile);
  }

  @Get('masters/:userId/public')
  async getPublicMasterProfile(@Param('userId') userId: string) {
    const profile = await this.profilesService.getPublicMasterProfile(userId);
    return ok(profile);
  }

  @Patch('masters/:userId')
  async updateMasterProfile(
    @Param('userId') userId: string,
    @Body() dto: UpdateMasterProfileDto,
  ) {
    const profile = await this.profilesService.updateMasterProfile(userId, dto);
    return ok(profile);
  }

  @Post('masters/:userId/categories')
  async setMasterCategories(
    @Param('userId') userId: string,
    @Body() dto: SetMasterCategoriesDto,
  ) {
    const profile = await this.profilesService.setMasterCategories(userId, dto.categorySlugs);
    return ok(profile);
  }
}
