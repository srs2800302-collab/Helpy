import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const categories = [
  'cleaning',
  'handyman',
  'plumbing',
  'electrical',
  'locks',
  'aircon',
  'furniture_assembly',
] as const;

async function main() {
  for (const [index, slug] of categories.entries()) {
    await prisma.serviceCategory.upsert({
      where: { slug },
      update: {
        isActive: true,
        sortOrder: index,
      },
      create: {
        slug,
        isActive: true,
        sortOrder: index,
      },
    });
  }

  const result = await prisma.serviceCategory.findMany({
    orderBy: [{ sortOrder: 'asc' }, { slug: 'asc' }],
  });

  console.log(JSON.stringify(result, null, 2));
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
