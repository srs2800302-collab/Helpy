import { IsString, MaxLength } from 'class-validator';

export class CreateDisputeDto {
  @IsString()
  jobId!: string;

  @IsString()
  openedByUserId!: string;

  @IsString()
  @MaxLength(2000)
  reason!: string;
}
