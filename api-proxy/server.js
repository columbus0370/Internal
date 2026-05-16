import express from 'express';
import cors from 'cors';
import fetch from 'node-fetch';

const app = express();
const PORT = process.env.PORT || 3000;
const CLAUDE_API_KEY = process.env.CLAUDE_API_KEY;

app.use(cors());
app.use(express.json());

if (!CLAUDE_API_KEY) {
  console.error('Error: CLAUDE_API_KEY environment variable not set');
  process.exit(1);
}

app.post('/api/predict-match', async (req, res) => {
  try {
    const { homeTeam, awayTeam } = req.body;

    const prompt = `
You are an expert football analyst. Predict a Premier League match between ${homeTeam.name} and ${awayTeam.name}.

HOME TEAM: ${homeTeam.name}
- Attack Power: ${homeTeam.attackPower}
- Defense Power: ${homeTeam.defensePower}
- Ball Control: ${homeTeam.ballControl}
- Formation: ${homeTeam.formation}
- Key Players: ${homeTeam.players.slice(0, 5).map((p) => p.name).join(', ')}

AWAY TEAM: ${awayTeam.name}
- Attack Power: ${awayTeam.attackPower}
- Defense Power: ${awayTeam.defensePower}
- Ball Control: ${awayTeam.ballControl}
- Formation: ${awayTeam.formation}
- Key Players: ${awayTeam.players.slice(0, 5).map((p) => p.name).join(', ')}

Return ONLY a valid JSON object (no additional text) with this exact structure:
{
  "homeScore": <int>,
  "awayScore": <int>,
  "homeTeamMom": "<player name>",
  "awayTeamMom": "<player name>",
  "goals": [
    {"minute": <int 1-90>, "team": "home" or "away", "scorer": "<player name>", "assist": "<player name or null>"}
  ],
  "stats": {
    "home": {
      "possession": <int 30-70>,
      "shots": <int 8-20>,
      "onTarget": <int 2-10>,
      "passes": <int 300-600>,
      "passAccuracy": <float 75-95>,
      "tackles": <int 10-25>,
      "aerialDuels": <int 15-30>,
      "fouls": <int 5-20>,
      "yellowCards": <int 0-5>,
      "redCards": <int 0-2>,
      "xg": <float 0.5-3.5>,
      "corners": <int 2-10>,
      "dribbles": <int 10-40>
    },
    "away": {
      "possession": <int 30-70>,
      "shots": <int 8-20>,
      "onTarget": <int 2-10>,
      "passes": <int 300-600>,
      "passAccuracy": <float 75-95>,
      "tackles": <int 10-25>,
      "aerialDuels": <int 15-30>,
      "fouls": <int 5-20>,
      "yellowCards": <int 0-5>,
      "redCards": <int 0-2>,
      "xg": <float 0.5-3.5>,
      "corners": <int 2-10>,
      "dribbles": <int 10-40>
    }
  },
  "highlights": ["<event description>", "<event description>"]
}

Make realistic predictions based on team strengths. Ensure possession adds up to 100.
`;

    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': CLAUDE_API_KEY,
        'anthropic-version': '2024-06-01',
      },
      body: JSON.stringify({
        model: 'claude-sonnet-4-6',
        max_tokens: 1500,
        messages: [
          {
            role: 'user',
            content: prompt,
          },
        ],
      }),
    });

    if (!response.ok) {
      throw new Error(`Claude API error: ${response.status}`);
    }

    const data = await response.json();
    const content = data.content[0].text;

    const jsonMatch = content.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      throw new Error('No JSON found in response');
    }

    const matchJson = JSON.parse(jsonMatch[0]);
    res.json(matchJson);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`API proxy server running on port ${PORT}`);
});
