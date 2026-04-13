export async function getUserJobDetails(userId: string, jobId: string, request: Request, env: any) {
  return Response.json(
    {
      success: false,
      error: 'DEBUG_JOB_DETAILS_MARKER',
      userId,
      jobId,
    },
    { status: 418 }
  );
}
