function firstNonEmptyString(values: Array<unknown>): string | null {
  for (const value of values) {
    if (typeof value === 'string' && value.trim().length > 0) {
      return value.trim();
    }
  }
  return null;
}

export function getRequestUserId(request: Request): string | null {
  return firstNonEmptyString([
    request.headers.get('x-user-id'),
    request.headers.get('X-User-Id'),
  ]);
}

export function requireRequestUserId(
  request: Request,
): { ok: true; userId: string } | { ok: false; response: Response } {
  const userId = getRequestUserId(request);

  if (!userId) {
    return {
      ok: false,
      response: Response.json(
        {
          success: false,
          error: 'x-user-id header is required',
        },
        { status: 400 },
      ),
    };
  }

  return {
    ok: true,
    userId,
  };
}
