export function buildJobInclude() {
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
        { sortOrder: 'asc' },
        { createdAt: 'asc' },
      ],
    },
    offers: {
      orderBy: [
        { createdAt: 'desc' },
      ],
    },
    payments: {
      orderBy: [
        { createdAt: 'desc' },
      ],
    },
  };
}

export function buildOfferInclude() {
  return {
    job: {
      include: {
        category: true,
        photos: {
          orderBy: [
            { sortOrder: 'asc' },
            { createdAt: 'asc' },
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
