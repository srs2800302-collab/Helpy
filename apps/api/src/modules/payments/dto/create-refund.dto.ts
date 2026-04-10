import { IsNumber, IsOptional, IsString, MaxLength, Min } from 'class-validator';

export class CreateRefundDto {
  @IsString()
  jobId!: string;

  @IsString()
  userId!: string;

  @IsNumber()
  @Min(0)
  amount!: number;

  @IsOptional()
  @IsString()
  @MaxLength(10)
  currency?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  provider?: string;

  @IsOptional()
  @IsString()
  @MaxLength(200)
  providerRef?: string;
}
