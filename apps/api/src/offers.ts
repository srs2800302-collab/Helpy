type CreateOfferBody = {
  master_name?: string;
  price?: number;
  comment?: string;
};

export async function createOffer(jobId: string, request: Request, env: any) {
  let body: CreateOfferBody;

  try {
    body = await request.json();
  } catch {
    return Response.json(
      { success: false, error: 'Invalid JSON body' },
      { status: 400 }
    );
  }

  if (!body.master_name || typeof body.price !== 'number') {
    return Response.json(
      { success: false, error: 'master_name and price are required' },
      { status: 400 }
    );
  }

  try {
    const id = crypto.randomUUID();

    await env.DB.prepare(
      'INSERT INTO offers (id, job_id, master_name, price, comment, created_at) VALUES (?1, ?2, ?3, ?4, ?5, ?6)'
    )
      .bind(
        id,
        jobId,
        body.master_name,
        body.price,
        body.comment ?? null,
        new Date().toISOString()
      )
      .run();

    return Response.json(
      {
        success: true,
        data: {
          id,
          job_id: jobId,
          master_name: body.master_name,
          price: body.price,
          comment: body.comment ?? null,
        },
      },
      { status: 201 }
    );
  } catch (error: any) {
    return Response.json(
      {
        success: false,
        error: error?.message ?? 'Failed to create offer',
      },
      { status: 500 }
    );
  }
}

export async function getOffers(jobId: string, env: any) {
  try {
    const result = await env.DB.prepare(
      'SELECT * FROM offers WHERE job_id = ?1 ORDER BY created_at DESC'
    )
      .bind(jobId)
      .all();

    return Response.json({
      success: true,
      data: result.results ?? [],
    });
  } catch (error: any) {
    return Response.json(
      {
        success: false,
        error: error?.message ?? 'Failed to fetch offers',
      },
      { status: 500 }
    );
  }
}
