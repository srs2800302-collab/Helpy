import { IsString } from 'class-validator';

export class SelectOfferDto {
  @IsString()
  clientUserId!: string;
}
