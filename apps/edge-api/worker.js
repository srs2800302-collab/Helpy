function json(data, init = {}) {
  return new Response(JSON.stringify(data), {
    ...init,
    headers: {
      "content-type": "application/json; charset=utf-8",
      ...(init.headers || {}),
    },
  });
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

    return json(
      {
        success: false,
        error: {
          code: "NOT_FOUND",
          message: "Route not found",
        },
      },
      { status: 404 }
    );
  },
};
