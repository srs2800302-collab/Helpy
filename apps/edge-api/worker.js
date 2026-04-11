function json(data, init = {}) {
  return new Response(JSON.stringify(data), {
    ...init,
    headers: {
      "content-type": "application/json; charset=utf-8",
      ...(init.headers || {}),
    },
  });
}

function errorResponse(status, code, message, details = null) {
  return json(
    {
      success: false,
      error: { code, message, details },
    },
    { status }
  );
}

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

function serializeJob(row) {
  if (!row) return null;
  return {
    id: row.id,
    client_id: row.client_id,
    category: row.category,
    title: row.title,
    description: row.description,
    address_text: row.address_text,
    budget_type: row.budget_type,
    budget_from: row.budget_from,
    budget_to: row.budget_to,
    currency: row.currency,
    status: row.status,
    created_at: row.created_at,
    updated_at: row.updated_at,
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

async function ensureSchema(DB) {
  await DB.prepare(`
    CREATE TABLE IF NOT EXISTS jobs (
      id TEXT PRIMARY KEY,
      client_id TEXT NOT NULL,
      category TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      address_text TEXT,
      budget_type TEXT,
      budget_from REAL,
      budget_to REAL,
      currency TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  `).run();
}

export default {
  async fetch(request, env) {
    try {
      const url = new URL(request.url);
      const { pathname } = url;
      const DB = env.DB;

      if (!DB) {
        return errorResponse(500, "DB_NOT_CONFIGURED", "D1 binding DB is missing");
      }

      await ensureSchema(DB);

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
        const id = crypto.randomUUID();
        const client_id = body.client_id || "mock-client-id";
        const category = body.category;
        const title = body.title.trim();
        const description = body.description.trim();
        const address_text = body.address_text || "Pattaya";
        const budget_type = body.budget_type || "fixed";
        const budget_from = body.budget_from ?? null;
        const budget_to = body.budget_to ?? null;
        const currency = body.currency || "THB";
        const status = "draft";

        await DB.prepare(`
          INSERT INTO jobs (
            id, client_id, category, title, description, address_text,
            budget_type, budget_from, budget_to, currency, status, created_at, updated_at
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `).bind(
          id,
          client_id,
          category,
          title,
          description,
          address_text,
          budget_type,
          budget_from,
          budget_to,
          currency,
          status,
          now,
          now
        ).run();

        const row = await DB.prepare(
          `SELECT * FROM jobs WHERE id = ?`
        ).bind(id).first();

        return json(
          {
            success: true,
            data: serializeJob(row),
          },
          { status: 201 }
        );
      }

      if (request.method === "GET" && pathname === "/api/v1/jobs") {
        const result = await DB.prepare(
          `SELECT * FROM jobs ORDER BY created_at DESC`
        ).all();

        return json({
          success: true,
          data: (result.results || []).map(serializeJob),
        });
      }

      const patchStatusMatch = pathname.match(/^\/api\/v1\/jobs\/([^/]+)\/status$/);

      if (request.method === "PATCH" && patchStatusMatch) {
        const jobId = patchStatusMatch[1];

        const existing = await DB.prepare(
          `SELECT * FROM jobs WHERE id = ?`
        ).bind(jobId).first();

        if (!existing) {
          return errorResponse(404, "JOB_NOT_FOUND", "Job not found");
        }

        const body = await readJsonBody(request);
        const validationError = validateStatusUpdate(existing.status, body?.status);

        if (validationError) {
          return errorResponse(400, "VALIDATION_ERROR", validationError);
        }

        const updated_at = new Date().toISOString();

        await DB.prepare(`
          UPDATE jobs
          SET status = ?, updated_at = ?
          WHERE id = ?
        `).bind(body.status, updated_at, jobId).run();

        const updated = await DB.prepare(
          `SELECT * FROM jobs WHERE id = ?`
        ).bind(jobId).first();

        return json({
          success: true,
          data: serializeJob(updated),
        });
      }

      const getJobMatch = pathname.match(/^\/api\/v1\/jobs\/([^/]+)$/);

      if (request.method === "GET" && getJobMatch) {
        const jobId = getJobMatch[1];

        const row = await DB.prepare(
          `SELECT * FROM jobs WHERE id = ?`
        ).bind(jobId).first();

        if (!row) {
          return errorResponse(404, "JOB_NOT_FOUND", "Job not found");
        }

        return json({
          success: true,
          data: serializeJob(row),
        });
      }

      return errorResponse(404, "NOT_FOUND", "Route not found");
    } catch (err) {
      return errorResponse(
        500,
        "UNHANDLED_EXCEPTION",
        err?.message || "Unknown error",
        {
          name: err?.name || null,
          stack: err?.stack || null,
        }
      );
    }
  },
};
