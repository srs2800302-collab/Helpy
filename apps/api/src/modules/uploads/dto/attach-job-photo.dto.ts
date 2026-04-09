import { IsOptional, IsString, MaxLength, Min, IsInt } from 'class-validator';

export class AttachJobPhotoDto {
  @IsString()
  jobId!: string;

  @IsString()
  @MaxLength(2000)
  url!: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  sortOrder?: number;
}
