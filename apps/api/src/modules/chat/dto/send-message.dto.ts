import { IsString, MaxLength, MinLength } from 'class-validator';

export class SendMessageDto {
  @IsString()
  jobId!: string;

  @IsString()
  senderUserId!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(4000)
  text!: string;
}
