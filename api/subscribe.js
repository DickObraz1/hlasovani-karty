export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { email, name } = req.body;

  const response = await fetch('https://api2.ecomailapp.cz/lists/19/subscribe', {
    method: 'POST',
    headers: {
      'key': process.env.ECOMAIL_API_KEY,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      subscriber_data: { email: email, name: name, tags: ['hlasovani'] },
      trigger_autoresponders: true,
      update_existing: true,
      resubscribe: false,
    }),
  });

  const data = await response.json();
  return res.status(200).json(data);
}
