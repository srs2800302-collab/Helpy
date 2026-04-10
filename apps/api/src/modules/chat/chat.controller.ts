import { Body, Controller, Get, Param, Patch, Post, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { ok } from '../../common/types/api-response.type';
import { ListMessagesQueryDto } from './dto/list-messages-query.dto';
import { SendMessageDto } from './dto/send-message.dto';
import { UpdateJobStatusDto } from './dto/update-job-status.dto';
import { ChatService } from './chat.service';

@ApiTags('chat')
@Controller('chat')
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Get('job/:jobId')
  async listMessages(@Param('jobId') jobId: string, @Query() query: ListMessagesQueryDto) {
    const messages = await this.chatService.listMessages(jobId, query.viewerUserId);
    return ok(messages);
  }

  @Post('messages')
  async sendMessage(@Body() dto: SendMessageDto) {
    const message = await this.chatService.sendMessage(dto);
    return ok(message);
  }

  @Patch('job/:jobId/status')
  async updateJobStatus(@Param('jobId') jobId: string, @Body() dto: UpdateJobStatusDto) {
    const job = await this.chatService.updateJobStatus(jobId, dto);
    return ok(job);
  }
}
