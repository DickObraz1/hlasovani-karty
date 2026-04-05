export default async function handler(req, res) {
  const headers = {
    'apikey': process.env.SUPABASE_SECRET_KEY,
    'Authorization': `Bearer ${process.env.SUPABASE_SECRET_KEY}`,
    'Prefer': 'count=exact',
  };

  const [cardsRes, usersRes] = await Promise.all([
    fetch('https://lixnqbjlozrqceixmbft.supabase.co/rest/v1/cards?select=id', { headers }),
    fetch('https://lixnqbjlozrqceixmbft.supabase.co/rest/v1/contestants?select=id', { headers }),
  ]);

  const parseCount = (r) => {
    const cr = r.headers.get('content-range');
    return cr ? parseInt(cr.split('/')[1]) : 0;
  };

  return res.status(200).json({
    cards: parseCount(cardsRes),
    users: parseCount(usersRes),
  });
}
