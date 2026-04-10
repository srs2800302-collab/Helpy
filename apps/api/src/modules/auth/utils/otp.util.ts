import { OTP_CODE_LENGTH } from '../constants/auth.constants';

export function generateOtpCode(): string {
  const min = 10 ** (OTP_CODE_LENGTH - 1);
  const max = 10 ** OTP_CODE_LENGTH - 1;
  const value = Math.floor(Math.random() * (max - min + 1)) + min;
  return String(value);
}
