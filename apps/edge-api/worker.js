function json(data, init = {}) {
  return new Response(JSON.stringify(data), {
    ...init,
    headers: {
      "content-type": "application/json; charset=utf-8",
      ...(init.headers || {}),
    },
  });
}

function errorResponse(status, code, message) {
  return json(
    {
      success: false,
      error: {
        code,
        message,
      },
    },
    { status }
  );
}

function generateId() {
  return crypto.randomUUID();
}

const jobsStore = new Map();

const allowedCategories = [
  "cleaning",
  "handyman",
  "plumbing",
  "electrical",
  "locks",
  "aircon",
  "furniture_assembly",
];

const allowedStatuses = [
  "draft",
  "awaiting_payment",
  "open",
  "master_selected",
  "in_progress",
  "completed",
  "cancelled",
  "disputed",
];

const allowedTransitions = {
  draft: ["awaiting_payment", "cancelled"],
  awaiting_payment: ["open", "cancelled"],
  open: ["master_selected", "cancelled"],
  master_selected: ["in_progress", "cancelled"],
  in_progress: ["completed", "cancelled", "disputed"],
  completed: [],
  cancelled: [],
  disputed: [],
};

function serializeJob(job) {
  return {
    id: job.id,
    client_id: job.client_id,
    category: job.category,
    title: job.title,
    description: job.description,
    address_text: job.address_text,
    budget_type: job.budget_type,
    budget_from: job.budget_from,
    budget_to: job.budget_to,
    currency: job.currency,
    status: job.status,
    created_at: job.created_at,
    updated_at: job.updated_at,
  };
}

async function readJsonBody(request) {
  try {
    return await request.json();
  } catch {
    return null;
  }
}

function validateCreateJob(body) {
  if (!body || typeof body !== "object") {
    return "Body must be a valid JSON object";
  }

  if (!body.category || typeof body.category !== "string") {
    return "category is required";
  }

  if (!body.title || typeof body.title !== "string") {
    return "title is required";
  }

  if (!body.description || typeof body.description !== "string") {
    return "description is required";
  }

  if (!allowedCategories.includes(body.category)) {
    return "category is invalid";
  }

  return null;
}

function validateStatusUpdate(currentStatus, nextStatus) {
  if (!nextStatus || typeof nextStatus !== "string") {
    return "status is required";
  }

  if (!allowedStatuses.includes(nextStatus)) {
    return "status is invalid";
  }

  const allowedNext = allowedTransitions[currentStatus] || [];
  if (!allowedNext.includes(nextStatus)) {
    return `cannot change status from ${currentStatus} to ${nextStatus}`;
  }

  return null;
}

export default {
  async fetch(request) {
    const url = new URL(request.url);
    const { pathname } = url;

    if (pathname === "/") {
      return json({
        success: true,
        service: "fixi-edge-api",
        message: "worker is running",
      });
    }

    if (pathname === "/health") {
      return json({
        success: true,
        service: "fixi-edge-api",
        status: "ok",
      });
    }

    const paymentStatusMatch = pathname.match(
      /^\/api\/v1\/jobs\/([^/]+)\/payment-status$/
    );

    if (request.method === "GET" && paymentStatusMatch) {
      const jobId = paymentStatusMatch[1];

      return json({
        success: true,
        data: {
          job_id: jobId,
          deposit_paid: true,
          payment: {
            id: "mock-payment-id",
            job_id: jobId,
            status: "paid",
            amount: 1000,
            currency: "THB",
          },
        },
      });
    }

    if (request.method === "POST" && pathname === "/api/v1/jobs") {
      const body = await readJsonBody(request);
      const validationError = validateCreateJob(body);

      if (validationError) {
        return errorResponse(400, "VALIDATION_ERROR", validationError);
      }

      const now = new Date().toISOString();
      const job = {
        id: generateId(),
        client_id: body.client_id || "mock-client-id",
        category: body.category,
        title: body.title.trim(),
        description: body.description.trim(),
        address_text: body.address_text || "Pattaya",
        budget_type: body.budget_type || "fixed",
        budget_from: body.budget_from ?? null,
        budget_to: body.budget_to ?? null,
        currency: body.currency || "THB",
        status: "draft",
        created_at: now,
        updated_at: now,
      };

      jobsStore.set(job.id, job);

      return json(
        {
          success: true,
          data: serializeJob(job),
        },
        { status: 201 }
      );
    }

    if (request.method === "GET" && pathname === "/api/v1/jobs") {
      const jobs = Array.from(jobsStore.values()).map(serializeJob);

      return json({
        success: true,
        data: jobs,
      });
    }

    const patchStatusMatch = pathname.match(/^\/api\/v1\/jobs\/([^/]+)\/status$/);

    if (request.method === "PATCH" && patchStatusMatch) {
      const jobId = patchStatusMatch[1];
      const job = jobsStore.get(jobId);

      if (!job) {
        return errorResponse(404, "JOB_NOT_FOUND", "Job not found");
      }

      const body = await readJsonBody(request);
      const validationError = validateStatusUpdate(job.status, body?.status);

      if (validationError) {
        return errorResponse(400, "VALIDATION_ERROR", validationError);
      }

      job.status = body.status;
      job.updated_at = new Date().toISOString();
      jobsStore.set(job.id, job);

      return json({
        success: true,
        data: serializeJob(job),
      });
    }

    const getJobMatch = pathname.match(/^\/api\/v1\/jobs\/([^/]+)$/);

    if (request.method === "GET" && getJobMatch) {
      const jobId = getJobMatch[1];
      const job = jobsStore.get(jobId);

      if (!job) {
        return errorResponse(404, "JOB_NOT_FOUND", "Job not found");
      }

      return json({
        success: true,
        data: serializeJob(job),
      });
    }

    return errorResponse(404, "NOT_FOUND", "Route not found");
  },
};
