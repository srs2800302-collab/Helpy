import { IsOptional, IsString, MaxLength } from 'class-validator';

export class MarkPaymentPaidDto {
  @IsOptional()
  @IsString()
  @MaxLength(100)
  provider?: string;

  @IsOptional()
  @IsString()
  @MaxLength(200)
  providerRef?: string;
}
