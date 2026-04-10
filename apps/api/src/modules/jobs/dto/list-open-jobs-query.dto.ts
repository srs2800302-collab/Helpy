import { IsOptional, IsString } from 'class-validator';

export class ListOpenJobsQueryDto {
  @IsOptional()
  @IsString()
  categoryId?: string;

  @IsOptional()
  @IsString()
  masterUserId?: string;
}
