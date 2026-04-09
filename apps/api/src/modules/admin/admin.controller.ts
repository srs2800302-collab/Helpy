import { Controller, Get, Param, Patch } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { MasterVerificationStatus } from '@prisma/client';
import { ok } from '../../common/types/api-response.type';
import { AdminService } from './admin.service';

@ApiTags('admin')
@Controller('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('dashboard')
  async getDashboard() {
    const data = await this.adminService.getDashboard();
    return ok(data);
  }

  @Get('masters')
  async listMasters() {
    const data = await this.adminService.listMasters();
    return ok(data);
  }

  @Patch('masters/:userId/approve')
  async approveMaster(@Param('userId') userId: string) {
    const data = await this.adminService.updateMasterVerificationStatus(
      userId,
      MasterVerificationStatus.approved,
    );
    return ok(data);
  }

  @Patch('masters/:userId/reject')
  async rejectMaster(@Param('userId') userId: string) {
    const data = await this.adminService.updateMasterVerificationStatus(
      userId,
      MasterVerificationStatus.rejected,
    );
    return ok(data);
  }

  @Patch('masters/:userId/block')
  async blockMaster(@Param('userId') userId: string) {
    const data = await this.adminService.updateMasterVerificationStatus(
      userId,
      MasterVerificationStatus.blocked,
    );
    return ok(data);
  }

  @Get('jobs')
  async listJobs() {
    const data = await this.adminService.listJobs();
    return ok(data);
  }

  @Get('payments')
  async listPayments() {
    const data = await this.adminService.listPayments();
    return ok(data);
  }
}
