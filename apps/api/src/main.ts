import 'reflect-metadata';
import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { getAppConfig } from './config/env';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { AppModule } from './app.module';

async function bootstrap() {
  const config = getAppConfig();
  const app = await NestFactory.create(AppModule);

  app.setGlobalPrefix(config.apiPrefix);
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }),
  );
  app.useGlobalFilters(new HttpExceptionFilter());

  const swaggerConfig = new DocumentBuilder()
    .setTitle('Fixi API')
    .setDescription('Fixi MVP backend API')
    .setVersion('0.1.0')
    .build();

  const swaggerDocument = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('docs', app, swaggerDocument);

  await app.listen(config.port);

  console.log(
    JSON.stringify({
      message: 'Fixi API started',
      appName: config.appName,
      apiPrefix: config.apiPrefix,
      port: config.port,
    }),
  );
}

bootstrap();
