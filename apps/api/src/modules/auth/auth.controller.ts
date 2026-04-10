import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { BearerAuthGuard } from '../../common/guards/bearer-auth.guard';
import type { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';
import { RequestOtpDto } from './dto/request-otp.dto';
import { SelectMyRoleDto } from './dto/select-my-role.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { AuthService } from './auth.service';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('request-otp')
  requestOtp(@Body() dto: RequestOtpDto) {
    return this.authService.requestOtp(dto);
  }

  @Post('verify-otp')
  verifyOtp(@Body() dto: VerifyOtpDto) {
    return this.authService.verifyOtp(dto);
  }

  @ApiBearerAuth()
  @UseGuards(BearerAuthGuard)
  @Get('me')
  getCurrentUser(@CurrentUser() user: AuthenticatedUser | null) {
    return this.authService.getCurrentUser(user!.id);
  }

  @ApiBearerAuth()
  @UseGuards(BearerAuthGuard)
  @Post('select-role')
  selectMyRole(
    @CurrentUser() user: AuthenticatedUser | null,
    @Body() dto: SelectMyRoleDto,
  ) {
    return this.authService.selectMyRole(user!.id, dto);
  }
}
