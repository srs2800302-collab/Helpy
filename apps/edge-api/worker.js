export default {
  async fetch(request) {
    const url = new URL(request.url);

    if (url.pathname === "/health") {
      return new Response(
        JSON.stringify({
          success: true,
          service: "fixi-edge-api",
          status: "ok",
        }),
        {
          headers: {
            "content-type": "application/json; charset=utf-8",
          },
        }
      );
    }

    return new Response("Not Found", { status: 404 });
  },
};
