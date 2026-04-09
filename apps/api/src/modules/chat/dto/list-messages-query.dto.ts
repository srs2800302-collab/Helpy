import { IsString } from 'class-validator';

export class ListMessagesQueryDto {
  @IsString()
  viewerUserId!: string;
}
