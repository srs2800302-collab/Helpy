import { AppModule } from './app.module';

function bootstrap() {
  const app = new AppModule();

  console.log(
    JSON.stringify({
      message: 'Fixi API bootstrap ready',
      appName: app.config.appName,
      apiPrefix: app.config.apiPrefix,
      port: app.config.port,
      modules: ['health', 'prisma', 'auth'],
    }),
  );
}

bootstrap();
