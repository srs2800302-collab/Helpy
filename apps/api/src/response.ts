export function ok(data: any, status = 200) {
  return Response.json({ success: true, data }, { status });
}

export function fail(error: string, status = 400) {
  return Response.json({ success: false, error }, { status });
}
