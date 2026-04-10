import { IsIn, IsOptional, IsString, MaxLength } from 'class-validator';

export class UpdateDisputeStatusDto {
  @IsIn(['open', 'in_review', 'resolved', 'rejected'])
  status!: 'open' | 'in_review' | 'resolved' | 'rejected';

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  resolutionNote?: string;
}
