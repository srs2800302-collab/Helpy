import { Prisma } from '@prisma/client';

export function buildJobInclude(): Prisma.JobInclude {
  return {
    client: {
      select: {
        id: true,
        phone: true,
        role: true,
      },
    },
    category: true,
    photos: {
      orderBy: [
        { sortOrder: Prisma.SortOrder.asc },
        { createdAt: Prisma.SortOrder.asc },
      ],
    },
    offers: {
      orderBy: [
        { createdAt: Prisma.SortOrder.desc },
      ],
    },
    payments: {
      orderBy: [
        { createdAt: Prisma.SortOrder.desc },
      ],
    },
  };
}

export function buildOfferInclude(): Prisma.JobOfferInclude {
  return {
    job: {
      include: {
        category: true,
        photos: {
          orderBy: [
            { sortOrder: Prisma.SortOrder.asc },
            { createdAt: Prisma.SortOrder.asc },
          ],
        },
      },
    },
    master: {
      select: {
        id: true,
        phone: true,
        role: true,
        masterProfile: true,
      },
    },
  };
}
