import { Prisma, SortOrder } from '@prisma/client';

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
        { sortOrder: SortOrder.asc },
        { createdAt: SortOrder.asc },
      ],
    },
    offers: {
      orderBy: [
        { createdAt: SortOrder.desc },
      ],
    },
    payments: {
      orderBy: [
        { createdAt: SortOrder.desc },
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
            { sortOrder: SortOrder.asc },
            { createdAt: SortOrder.asc },
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
