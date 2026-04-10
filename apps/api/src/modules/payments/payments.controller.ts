import { Body, Controller, Get, Param, Patch, Post } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { ok } from '../../common/types/api-response.type';
import { CreateDepositDto } from './dto/create-deposit.dto';
import { CreateRefundDto } from './dto/create-refund.dto';
import { MarkPaymentPaidDto } from './dto/mark-payment-paid.dto';
import { PaymentsService } from './payments.service';

@ApiTags('payments')
@Controller('payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Post('deposit')
  async createDeposit(@Body() dto: CreateDepositDto) {
    const payment = await this.paymentsService.createDeposit(dto);
    return ok(payment);
  }

  @Patch(':paymentId/mark-paid')
  async markPaid(@Param('paymentId') paymentId: string, @Body() dto: MarkPaymentPaidDto) {
    const payment = await this.paymentsService.markPaid(paymentId, dto);
    return ok(payment);
  }

  @Post('refund')
  async createRefund(@Body() dto: CreateRefundDto) {
    const payment = await this.paymentsService.createRefund(dto);
    return ok(payment);
  }

  @Get(':paymentId')
  async getById(@Param('paymentId') paymentId: string) {
    const payment = await this.paymentsService.getById(paymentId);
    return ok(payment);
  }

  @Get('job/:jobId')
  async listByJob(@Param('jobId') jobId: string) {
    const payments = await this.paymentsService.listByJob(jobId);
    return ok(payments);
  }
}
