const CLAUDE_MODEL = "claude-sonnet-4-6";
const CLAUDE_ENDPOINT = "https://api.anthropic.com/v1/messages";
const ANTHROPIC_VERSION = "2024-06-01";

const SYSTEM_PROMPT = `You are a Premier League match prediction expert. Generate realistic match predictions based on team data.

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

Each field must be filled with concrete and realistic content. Ensure possession adds up to 100.`;

module.exports = async (req, res) => {
  // CORS ヘッダー設定
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  // プリフライトリクエスト対応
  if (req.method === "OPTIONS") {
    return res.status(200).end();
  }

  if (req.method !== "POST") {
    return res.status(405).json({
      success: false,
      error: "Method not allowed",
    });
  }

  const apiKey = process.env.CLAUDE_API_KEY;

  if (!apiKey) {
    return res.status(500).json({
      success: false,
      error: "CLAUDE_API_KEY is not set",
    });
  }

  const { homeTeam, awayTeam } = req.body || {};

  if (!homeTeam || !awayTeam) {
    return res.status(400).json({
      success: false,
      error: "homeTeam and awayTeam objects are required",
    });
  }

  if (!homeTeam.name || !awayTeam.name) {
    return res.status(400).json({
      success: false,
      error: "Team names are required",
    });
  }

  try {
    const prompt = `Predict a Premier League match between ${homeTeam.name} and ${awayTeam.name}.

HOME TEAM: ${homeTeam.name}
- Attack Power: ${homeTeam.attackPower}
- Defense Power: ${homeTeam.defensePower}
- Ball Control: ${homeTeam.ballControl}
- Formation: ${homeTeam.formation}
- Key Players: ${homeTeam.players?.slice(0, 5).map((p) => p.name).join(", ") || "Unknown"}

AWAY TEAM: ${awayTeam.name}
- Attack Power: ${awayTeam.attackPower}
- Defense Power: ${awayTeam.defensePower}
- Ball Control: ${awayTeam.ballControl}
- Formation: ${awayTeam.formation}
- Key Players: ${awayTeam.players?.slice(0, 5).map((p) => p.name).join(", ") || "Unknown"}

Generate realistic match prediction based on team strengths.`;

    const response = await fetch(CLAUDE_ENDPOINT, {
      method: "POST",
      headers: {
        "x-api-key": apiKey,
        "anthropic-version": ANTHROPIC_VERSION,
        "content-type": "application/json",
      },
      body: JSON.stringify({
        model: CLAUDE_MODEL,
        max_tokens: 1500,
        system: SYSTEM_PROMPT,
        messages: [{ role: "user", content: prompt }],
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      console.error("Claude API error:", data);
      return res.status(response.status).json({
        success: false,
        error: `Claude API error (${response.status}): ${JSON.stringify(data)}`,
      });
    }

    const text = data?.content?.[0]?.text;

    if (!text) {
      console.error("Empty content from Claude:", data);
      return res.status(500).json({
        success: false,
        error: "Empty response from Claude",
      });
    }

    // JSON 前後のマークダウンコードフェンスを削除
    const cleaned = text.replaceAll("```json", "").replaceAll("```", "").trim();

    // JSON をパース
    const parsed = JSON.parse(cleaned);

    return res.status(200).json({
      success: true,
      data: parsed,
    });
  } catch (err) {
    console.error("Request failed:", err);
    return res.status(500).json({
      success: false,
      error: `Request failed: ${err.message}`,
    });
  }
};
