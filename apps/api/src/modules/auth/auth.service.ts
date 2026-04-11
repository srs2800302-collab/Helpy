import { Injectable } from '@nestjs/common';

const OTP_STORE = new Map<string, string>();

@Injectable()
export class AuthService {
  async requestOtp(phone: string) {
    const code = '1234';
    OTP_STORE.set(phone, code);

    console.log(`OTP for ${phone}: ${code}`);

    return { success: true };
  }

  async verifyOtp(phone: string, code: string) {
    const stored = OTP_STORE.get(phone);

    if (!stored || stored !== code) {
      return { success: false, error: 'INVALID_CODE' };
    }

    OTP_STORE.delete(phone);

    return {
      success: true,
      data: {
        access_token: 'mock-token',
        user: {
          id: 'temp-id',
          phone,
        },
      },
    };
  }
}
