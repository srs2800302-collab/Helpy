import { IsOptional, IsString } from 'class-validator';

export class ListClientJobsQueryDto {
  @IsString()
  clientUserId!: string;

  @IsOptional()
  @IsString()
  status?: string;
}
