import { Controller, Get, Post } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { ok } from '../../common/types/api-response.type';
import { CategoriesService } from './categories.service';

@ApiTags('categories')
@Controller('categories')
export class CategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Get()
  async list() {
    const items = await this.categoriesService.listActive();
    return ok(items);
  }

  @Post('seed')
  async seed() {
    const items = await this.categoriesService.seedMvpCategories();
    return ok(items);
  }
}
