type CreateJobBody = {
  title?: string;
  price?: number;
  category?: string;
};

type UpdateJobStatusBody = {
  status?: string;
};

const allowedStatuses = ['open', 'in_progress', 'completed'] as const;

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

export async function getJobById(jobId: string) {
  const job = mockJobs.find((item) => item.id === jobId);

  if (!job) {
    return Response.json(
      {
        success: false,
        error: 'Job not found',
      },
      { status: 404 },
    );
  }

  return Response.json({
    success: true,
    data: job,
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

export async function updateJobStatus(jobId: string, request: Request) {
  const job = mockJobs.find((item) => item.id === jobId);

  if (!job) {
    return Response.json(
      {
        success: false,
        error: 'Job not found',
      },
      { status: 404 },
    );
  }

  let body: UpdateJobStatusBody;

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

  if (!body.status || !allowedStatuses.includes(body.status as (typeof allowedStatuses)[number])) {
    return Response.json(
      {
        success: false,
        error: 'status must be one of: open, in_progress, completed',
      },
      { status: 400 },
    );
  }

  job.status = body.status;

  return Response.json({
    success: true,
    data: job,
  });
}
