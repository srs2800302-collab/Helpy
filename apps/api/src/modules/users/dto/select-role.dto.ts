import { IsIn } from 'class-validator';

export class SelectRoleDto {
  @IsIn(['client', 'master'])
  role!: 'client' | 'master';
}
