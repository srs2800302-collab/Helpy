import winston from 'winston';

export const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json(),
  ),
  transports: [
    new winston.transports.Console(),
    // Вы можете добавить File‑transport, если захотите хранить логи в файле
    // new winston.transports.File({ filename: 'logs/combined.log' })
  ],
});
