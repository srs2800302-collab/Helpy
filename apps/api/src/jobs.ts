type CreateJobBody = {
  title?: string;
  price?: number;
  category?: string;
};

const mockJobs = [
  {
    id: '1',
    title: 'Починить кондиционер',
    price: 1500,
    category: 'aircon',
    status: 'open',
  },
];

export async function getJobs() {
  return Response.json({
    success: true,
    data: mockJobs,
  });
}

export async function createJob(request: Request) {
  let body: CreateJobBody;

  try {
    body = await request.json();
  } catch {
    return Response.json(
      {
        success: false,
        error: 'Invalid JSON body',
      },
      { status: 400 },
    );
  }

  if (!body.title || !body.category || typeof body.price !== 'number') {
    return Response.json(
      {
        success: false,
        error: 'title, category, price are required',
      },
      { status: 400 },
    );
  }

  const newJob = {
    id: String(mockJobs.length + 1),
    title: body.title,
    price: body.price,
    category: body.category,
    status: 'open',
  };

  mockJobs.push(newJob);

  return Response.json(
    {
      success: true,
      data: newJob,
    },
    { status: 201 },
  );
}
