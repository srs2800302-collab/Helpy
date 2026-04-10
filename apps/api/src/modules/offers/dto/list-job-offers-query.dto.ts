import { IsOptional, IsString } from 'class-validator';

export class ListJobOffersQueryDto {
  @IsOptional()
  @IsString()
  clientUserId?: string;
}
