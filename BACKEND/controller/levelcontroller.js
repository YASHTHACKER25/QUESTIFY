export async function calculateLevel(points) {
  if (points >= 1000) return 'Expert';
  if (points >= 500)  return 'Advanced';
  if (points >= 200)  return 'Intermediate';
  return 'Beginner';
}