const CLAUDE_MODEL = "claude-sonnet-4-6";
const CLAUDE_ENDPOINT = "https://api.anthropic.com/v1/messages";
const ANTHROPIC_VERSION = "2023-06-01";

const SYSTEM_PROMPT = `あなたはサッカー試合分析の専門家です。試合予測データを受け取り、JSON形式で試合の詳細な分析を日本語で生成します。

必ず以下のJSONフォーマットのみで応答してください。説明文・前置き・コードフェンスは出力しないでください。

{
  "summary": "試合全体の簡潔な分析（2-3文）",
  "homeTeamAnalysis": "ホームチームの強み・弱み・戦術的特徴（3-4文）",
  "awayTeamAnalysis": "アウェイチームの強み・弱み・戦術的特徴（3-4文）",
  "tacticalPoints": "両チーム間の戦術的な相違点と対抗軸（2-3文）",
  "keyPlayers": "注目選手と試合への影響（3-4文）",
  "possessionAnalysis": "ボール保持率と支配権の意味（2文）",
  "prediction": "試合の流れ・スコア予測の根拠（3-4文）",
  "risks": "予測の不確実性・予想外の展開可能性（2文）"
}

各フィールドは空にせず、具体的かつ実用的な内容で埋めてください。スコア以外の要素を重視してください。`;

function generateFallbackAnalysis(prediction) {
  const homeTeam = prediction.homeTeam || {};
  const awayTeam = prediction.awayTeam || {};
  const homeTeamName = prediction.homeTeamName || "ホームチーム";
  const awayTeamName = prediction.awayTeamName || "アウェイチーム";

  return {
    summary: `${homeTeamName}が${awayTeamName}とのマッチアップで、戦力分析に基づいた試合展開が予想されます。両チームの攻撃力と守備力のバランスが試合の鍵となるでしょう。`,
    homeTeamAnalysis: `${homeTeamName}は攻撃力${homeTeam.attackPower || 85}、守備力${homeTeam.defensePower || 85}を持っています。ボール保持率${Math.round((prediction.possession || 0.5) * 100)}%の支配権を活かした戦術展開が期待されます。`,
    awayTeamAnalysis: `${awayTeamName}は攻撃力${awayTeam.attackPower || 80}、守備力${awayTeam.defensePower || 80}で対抗します。アウェイながらカウンター攻撃による得点機会の創出が重要な戦略となります。`,
    tacticalPoints: `${homeTeamName}のホーム有利を${awayTeamName}がどう攻略するかが焦点です。${homeTeamName}の支配的なボール保持に対し、${awayTeamName}の効率的な攻撃が対抗軸になるでしょう。`,
    keyPlayers: `${prediction.mom || "注目選手"}が試合の決定的な場面で活躍することが予想されます。${homeTeamName}のフォワードと${awayTeamName}のディフェンダーの対決が見どころとなります。`,
    possessionAnalysis: `ボール保持率${Math.round((prediction.possession || 0.5) * 100)}%は${homeTeamName}の支配的なボール保持を示唆しています。このボール支配をいかに得点に結び付けるかが勝敗を分ける要因となります。`,
    prediction: `両チームのバランスの取れた対戦になることが予想されます。最終スコアは${prediction.homeScore || 1}対${prediction.awayScore || 1}程度の接戦になるでしょう。`,
    risks: `予想外の個人的なエラーや怪我による退場が試合の流れを大きく変える可能性があります。セットプレーでの予期しない得点も考慮に入れる必要があります。`,
  };
}

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
    console.warn("CLAUDE_API_KEY not set, using fallback analysis");
    const fallbackAnalysis = generateFallbackAnalysis(req.body?.prediction || {});
    return res.status(200).json({
      success: true,
      analysis: fallbackAnalysis,
      source: "fallback",
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
      });
      // API エラーの場合はフォールバック分析を返す
      const fallbackAnalysis = generateFallbackAnalysis(prediction);
      return res.status(200).json({
        success: true,
        analysis: fallbackAnalysis,
        source: "fallback",
        error: `Claude API error (${response.status})`,
      });
    }

    const text = data?.content?.[0]?.text;

    if (!text) {
      console.error("Empty content from Claude:", data);
      const fallbackAnalysis = generateFallbackAnalysis(prediction);
      return res.status(200).json({
        success: true,
        analysis: fallbackAnalysis,
        source: "fallback",
        error: "Empty response from Claude",
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
