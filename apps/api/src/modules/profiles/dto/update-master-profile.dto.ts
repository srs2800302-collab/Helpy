import { IsBoolean, IsOptional, IsString, MaxLength } from 'class-validator';

export class UpdateMasterProfileDto {
  @IsOptional()
  @IsString()
  @MaxLength(100)
  firstName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  lastName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(150)
  displayName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  photoUrl?: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  bio?: string;

  @IsOptional()
  @IsBoolean()
  isAvailable?: boolean;
}
