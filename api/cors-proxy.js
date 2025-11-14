// CORS Proxy for fetching iCal data from schulnetz.lu.ch
// Vercel Serverless Function

export default async function handler(req, res) {
  // Only allow GET requests
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { url } = req.query;

  // Validate URL - only allow schulnetz.lu.ch
  if (!url || !url.startsWith('https://schulnetz.lu.ch/bbzw')) {
    return res.status(400).json({ 
      error: 'Invalid URL. Only schulnetz.lu.ch/bbzw URLs are allowed.' 
    });
  }

  try {
    // Fetch the iCal data
    const response = await fetch(url, {
      headers: {
        'User-Agent': 'Absendo/1.0'
      }
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.text();

    // Set CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET');
    res.setHeader('Content-Type', 'text/calendar');
    res.setHeader('Cache-Control', 'public, max-age=300'); // Cache for 5 minutes

    return res.status(200).send(data);

  } catch (error) {
    console.error('Proxy error:', error);
    return res.status(500).json({ 
      error: 'Failed to fetch calendar data',
      details: error.message 
    });
  }
}
