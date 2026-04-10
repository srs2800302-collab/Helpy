import {
  ArrayMinSize,
  IsArray,
  IsInt,
  IsOptional,
  IsString,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

class ReorderJobPhotoItemDto {
  @IsString()
  photoId!: string;

  @IsInt()
  @Min(0)
  sortOrder!: number;
}

export class ReorderJobPhotosDto {
  @IsOptional()
  @IsString()
  jobId?: string;

  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => ReorderJobPhotoItemDto)
  items!: ReorderJobPhotoItemDto[];
}
