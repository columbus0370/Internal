const CLAUDE_MODEL = "claude-sonnet-4-6";
const CLAUDE_ENDPOINT = "https://api.anthropic.com/v1/messages";
const ANTHROPIC_VERSION = "2023-06-01";

const SYSTEM_PROMPT = `あなたはプロのサッカー実況解説者です。試合予測データを受け取り、90分間の試合を時系列で実況する日本語テキストを生成します。

必ず以下のJSONフォーマットのみで応答してください。説明文・前置き・コードフェンスは出力しないでください。

{
  "narrative": "試合全体の実況（キックオフから試合終了まで、時系列で試合の流れを描写。各チームの攻め方・守り方、活躍選手、重要な場面を含む。500-1000字）",
  "summary": "試合全体の簡潔な総括（2-3文）",
  "keyMoments": [
    {
      "minute": "分単位の時間",
      "event": "イベント種別（ゴール/チャンス/警告/セーブなど）",
      "team": "チーム名",
      "description": "詳細な出来事の説明"
    }
  ]
}

narrativeフィールドは必ず具体的かつ自然な実況形式で、スコア以外の要素（戦術、選手の活躍、試合の流れ）を重視してください。`;

function generateFallbackAnalysis(prediction) {
  const homeTeam = prediction.homeTeam || {};
  const awayTeam = prediction.awayTeam || {};
  const homeTeamName = prediction.homeTeamName || "ホームチーム";
  const awayTeamName = prediction.awayTeamName || "アウェイチーム";
  const possession = Math.round((prediction.possession || 0.5) * 100);

  const narrative = `【前半】キックオフ。${homeTeamName}が${possession}%のボール保持率でゲームをコントロール。${homeTeamName}の中盤が${awayTeamName}のプレッシャーをかわしながら、サイドを経由した攻撃を展開。${prediction.mom || "注目選手"}が深い位置でボールを受け、チャンスを作り出す。${awayTeamName}は${possession > 50 ? "効率的なカウンター攻撃で" : "ボール奪取後の素早い攻撃で"}得点機会を伺う。前半の要所では両チームの中盤争いが激化。${homeTeamName}の守備力${homeTeam.defensePower || 85}とよく対応。

【後半】${awayTeamName}が攻撃的なフォーメーション変更で圧力を高める。${homeTeamName}は攻撃力${homeTeam.attackPower || 85}を活かし、${prediction.homeScore > prediction.awayScore ? "得点機会をものにして" : "シュート数を重ねるが"}スコアを重ねる。試合が動くのは${70 + Math.floor(Math.random() * 10)}分付近。${prediction.goals && prediction.goals.length > 0 ? prediction.goals.map(g => `${g.minute}分に${g.scorer}がゴール`).join("。") : "決定的な場面が続く"}。終盤に${awayTeamName}が${prediction.awayScore > prediction.homeScore ? "ゴール返し" : "追い詰めるが"}、最終的に${prediction.homeScore}対${prediction.awayScore}で試合終了。`;

  return {
    narrative: narrative,
    summary: `${homeTeamName}が${awayTeamName}を${prediction.homeScore}対${prediction.awayScore}で下す。${possession}%のボール保持から得られた支配的な試合展開。`,
    keyMoments: [
      {
        minute: "15分",
        event: "チャンス",
        team: homeTeamName,
        description: `${homeTeamName}が左サイドからの攻撃でゴール前にボールを供給するもキーパーが好セーブ`
      },
      ...(prediction.goals && prediction.goals.length > 0 ? prediction.goals.map(g => ({
        minute: `${g.minute}分`,
        event: "ゴール",
        team: g.team,
        description: `${g.scorer}がゴール。${g.team}が得点を重ねる重要な瞬間`
      })) : []),
      {
        minute: "85分",
        event: "警告",
        team: awayTeamName,
        description: `${awayTeamName}の選手が激しいタックルでイエローカード`
      }
    ]
  };
}

export default async (req, res) => {
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

  const apiKey = process.env.ANTHROPIC_API_KEY;

  if (!apiKey) {
    console.warn("ANTHROPIC_API_KEY not set, using fallback analysis");
    const fallbackAnalysis = generateFallbackAnalysis(req.body?.prediction || {});
    return res.status(200).json({
      success: true,
      analysis: fallbackAnalysis,
      source: "fallback",
      error: "ANTHROPIC_API_KEY environment variable not set",
    });
  }

  const prediction = req.body?.prediction;

  if (!prediction || typeof prediction !== "object") {
    return res.status(400).json({
      success: false,
      error: "prediction (object) is required in request body",
    });
  }

  try {
    const prompt = `以下の試合予測データに基づいて、詳細な試合分析を生成してください：

ホームチーム: ${prediction.homeTeamName || "ホームチーム"}
アウェイチーム: ${prediction.awayTeamName || "アウェイチーム"}
予測スコア: ${prediction.homeScore || 0} - ${prediction.awayScore || 0}

ホームチーム統計:
- 攻撃力: ${prediction.homeTeam?.attackPower || 80}
- 守備力: ${prediction.homeTeam?.defensePower || 80}
- ボール支配率: ${prediction.homeTeam?.ballControl || 50}

アウェイチーム統計:
- 攻撃力: ${prediction.awayTeam?.attackPower || 80}
- 守備力: ${prediction.awayTeam?.defensePower || 80}
- ボール支配率: ${prediction.awayTeam?.ballControl || 50}

試合統計:
- 全体的なボール保持率: ${Math.round((prediction.possession || 0.5) * 100)}%
- 注目選手: ${prediction.mom || "特定なし"}
- ゴール情報: ${(prediction.goals || []).length}得点`;

    const response = await fetch(CLAUDE_ENDPOINT, {
      method: "POST",
      headers: {
        "x-api-key": apiKey,
        "anthropic-version": ANTHROPIC_VERSION,
        "content-type": "application/json",
        "user-agent": "epl-match-simulator/1.0",
      },
      body: JSON.stringify({
        model: CLAUDE_MODEL,
        max_tokens: 2048,
        system: SYSTEM_PROMPT,
        messages: [{ role: "user", content: prompt }],
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      console.error("Claude API error:", {
        status: response.status,
        errorType: data.error?.type,
        errorMessage: data.error?.message,
        fullResponse: JSON.stringify(data),
      });
      // API エラーの場合はフォールバック分析を返す
      const fallbackAnalysis = generateFallbackAnalysis(prediction);
      return res.status(200).json({
        success: true,
        analysis: fallbackAnalysis,
        source: "fallback",
        error: `Claude API error (${response.status}): ${data.error?.message || "Unknown error"}`,
        apiErrorType: data.error?.type,
      });
    }

    const text = data?.content?.[0]?.text;

    if (!text) {
      console.error("Empty content from Claude:", {
        statusCode: response.status,
        contentLength: data?.content?.length,
        fullResponse: JSON.stringify(data),
      });
      const fallbackAnalysis = generateFallbackAnalysis(prediction);
      return res.status(200).json({
        success: true,
        analysis: fallbackAnalysis,
        source: "fallback",
        error: "Empty response from Claude",
        debugInfo: { statusCode: response.status, hasContent: !!data?.content },
      });
    }

    // JSON パースを試みる
    let analysis;
    try {
      analysis = JSON.parse(text);
    } catch (parseErr) {
      console.error("Failed to parse Claude response as JSON:", text);
      const fallbackAnalysis = generateFallbackAnalysis(prediction);
      return res.status(200).json({
        success: true,
        analysis: fallbackAnalysis,
        source: "fallback",
        error: "Failed to parse Claude response",
      });
    }

    return res.status(200).json({
      success: true,
      analysis,
      source: "claude",
    });
  } catch (err) {
    console.error("Request failed:", err);
    const fallbackAnalysis = generateFallbackAnalysis(req.body?.prediction || {});
    return res.status(200).json({
      success: true,
      analysis: fallbackAnalysis,
      source: "fallback",
      error: `Request failed: ${err.message}`,
    });
  }
};
