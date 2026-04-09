import { IsIn, IsString } from 'class-validator';

export class UpdateJobStatusDto {
  @IsString()
  actorUserId!: string;

  @IsIn(['in_progress', 'completed'])
  status!: 'in_progress' | 'completed';
}
