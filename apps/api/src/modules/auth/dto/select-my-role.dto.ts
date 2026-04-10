import { IsIn } from 'class-validator';

export class SelectMyRoleDto {
  @IsIn(['client', 'master'])
  role!: 'client' | 'master';
}
