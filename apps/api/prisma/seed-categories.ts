const categories = [
  'cleaning',
  'handyman',
  'plumbing',
  'electrical',
  'locks',
  'aircon',
  'furniture_assembly',
] as const;

for (const slug of categories) {
  console.log(JSON.stringify({ slug }));
}
