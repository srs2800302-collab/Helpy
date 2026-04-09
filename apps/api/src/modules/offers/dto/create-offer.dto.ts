import { IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateOfferDto {
  @IsString()
  jobId!: string;

  @IsString()
  masterUserId!: string;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  message?: string;

  @IsOptional()
  @IsString()
  @MaxLength(300)
  priceComment?: string;
}
