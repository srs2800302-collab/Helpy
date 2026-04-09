import { Body, Controller, Param, Patch } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { ok } from '../../common/types/api-response.type';
import { SelectRoleDto } from './dto/select-role.dto';
import { UsersService } from './users.service';

@ApiTags('users')
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Patch(':id/select-role')
  async selectRole(@Param('id') id: string, @Body() dto: SelectRoleDto) {
    const role = dto.role === 'client' ? UserRole.client : UserRole.master;
    const user = await this.usersService.setRole(id, role);

    return ok({
      id: user.id,
      role: user.role,
    });
  }
}
