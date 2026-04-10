export async function getJobs() {
  return Response.json({
    success: true,
    data: [
      {
        id: '1',
        title: 'Починить кондиционер',
        price: 1500,
        category: 'aircon',
      }
    ],
  });
}
