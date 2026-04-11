type ResolveUserOptions = {
  body?: any;
  bodyFields?: string[];
  queryFields?: string[];
};

function firstNonEmptyString(values: Array<unknown>): string | null {
  for (const value of values) {
    if (typeof value === 'string' && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

function parseUrlSafe(request: Request): URL | null {
  try {
    return new URL(request.url);
  } catch {
    return null;
  }
}

export function getRequestUserId(
  request: Request,
  options: ResolveUserOptions = {},
): string | null {
  const fromHeader = firstNonEmptyString([
    request.headers.get('x-user-id'),
    request.headers.get('X-User-Id'),
  ]);

  if (fromHeader) {
    return fromHeader;
  }

  const body = options.body ?? {};
  const bodyFields = options.bodyFields ?? [];
  const fromBody = firstNonEmptyString(
    bodyFields.map((field) => body?.[field]),
  );

  if (fromBody) {
    return fromBody;
  }

  const url = parseUrlSafe(request);
  const queryFields = options.queryFields ?? [];
  const fromQuery = firstNonEmptyString(
    queryFields.map((field) => url?.searchParams.get(field)),
  );

  if (fromQuery) {
    return fromQuery;
  }

  return null;
}

export function requireRequestUserId(
  request: Request,
  options: ResolveUserOptions = {},
): { ok: true; userId: string } | { ok: false; response: Response } {
  const userId = getRequestUserId(request, options);

  if (!userId) {
    return {
      ok: false,
      response: Response.json(
        {
          success: false,
          error: 'user_id is required',
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
