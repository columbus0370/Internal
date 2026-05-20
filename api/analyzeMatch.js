const CLAUDE_MODEL = "claude-sonnet-4-6";
const CLAUDE_ENDPOINT = "https://api.anthropic.com/v1/messages";
const ANTHROPIC_VERSION = "2023-06-01";

const SYSTEM_PROMPT = `あなたはプロのサッカー実況解説者です。試合予測データを受け取り、90分間の試合をクォーター別（15分ごと）に詳細な日本語実況を生成します。

必ず以下のJSONフォーマットのみで応答してください。説明文・前置き・コードフェンスは出力しないでください。

{
  "narrative_segments": [
    {
      "quarter": 1,
      "minute_range": "0-15分",
      "quarter_score": "スコア（例：1-0）",
      "narrative": "第1クォーターの実況（試合開始から15分までの流れ、両チームの立ち上がり、初期の攻防パターン、重要な場面。150-200字）",
      "quarter_summary": "第1クォーターの総括（1-2文）",
      "events": [
        {
          "minute": "分単位",
          "team": "チーム名",
          "event": "イベント種別（ゴール/チャンス/警告など）",
          "description": "詳細説明"
        }
      ]
    },
    {
      "quarter": 2,
      "minute_range": "15-45分",
      "quarter_score": "スコア",
      "narrative": "第2クォーターの実況（15-45分、前半のピークシーン、戦術調整、ハーフタイム前の流れ。150-200字）",
      "quarter_summary": "第2クォーターの総括（1-2文）",
      "events": []
    },
    {
      "quarter": 3,
      "minute_range": "45-60分",
      "quarter_score": "スコア",
      "narrative": "第3クォーターの実況（後半開始から60分、後半の新しい流れ、フォーメーション変更の影響。150-200字）",
      "quarter_summary": "第3クォーターの総括（1-2文）",
      "events": []
    },
    {
      "quarter": 4,
      "minute_range": "60-90分",
      "quarter_score": "最終スコア",
      "narrative": "第4クォーターの実況（60分から試合終了まで、終盤の緊張感、決定的場面、試合の決着。150-200字）",
      "quarter_summary": "第4クォーターの総括（1-2文）",
      "events": []
    }
  ],
  "overall_summary": "試合全体の簡潔な総括（2-3文）",
  "key_moments": [
    {
      "minute": "分単位の時間",
      "team": "チーム名",
      "event": "イベント種別（ゴール/チャンス/警告など）",
      "description": "詳細な出来事の説明"
    }
  ]
}

重要指示：
- 各quarter_scoreは累積スコア（その時点までの合計得点）を示してください
- narrativeは具体的かつ自然な実況形式で、戦術・選手の活躍・試合の流れを重視
- 各クォーターで独立した実況を生成し、流れがある程度つながるようにしてください`;

function generateFallbackAnalysis(prediction) {
  const homeTeam = prediction.homeTeam || {};
  const awayTeam = prediction.awayTeam || {};
  const homeTeamName = prediction.homeTeamName || "ホームチーム";
  const awayTeamName = prediction.awayTeamName || "アウェイチーム";
  const possession = Math.round((prediction.possession || 0.5) * 100);
  const goals = prediction.goals || [];

  const calculateQuarterScore = (quarterNum) => {
    const goalsUpToQuarter = goals.filter(g => {
      const minute = parseInt(g.minute) || 0;
      const quarterEnd = quarterNum * 15;
      return minute <= quarterEnd;
    });
    let homeGoals = 0, awayGoals = 0;
    goalsUpToQuarter.forEach(g => {
      if (g.team === homeTeamName) homeGoals++;
      else awayGoals++;
    });
    return `${homeGoals}-${awayGoals}`;
  };

  const getQuarterGoals = (quarterNum) => {
    const quarterStart = (quarterNum - 1) * 15;
    const quarterEnd = quarterNum === 4 ? 90 : quarterNum * 15;
    return goals.filter(g => {
      const minute = parseInt(g.minute) || 0;
      return minute > quarterStart && minute <= quarterEnd;
    });
  };

  return {
    narrative_segments: [
      {
        quarter: 1,
        minute_range: "0-15分",
        quarter_score: calculateQuarterScore(1),
        narrative: `キックオフ。${homeTeamName}が${possession}%のボール保持率で試合を支配。序盤から${homeTeam.attackPower > 80 ? "積極的な高圧攻撃" : "組織的な組み立て"}を展開。${awayTeamName}は${awayTeam.defensePower > 80 ? "堅固な守備ブロック" : "スペースを活用した防御"}で対抗。${possession > 50 ? "ホームチームがボールの主導権を握り" : "アウェイチームがプレッシングで"}、中盤での激しい競り合いが展開される。`,
        quarter_summary: `${possession > 50 ? "ホームチーム優位で序盤を進める" : "接戦の中での立ち上がり"}。`,
        events: getQuarterGoals(1).map(g => ({
          minute: `${g.minute}分`,
          team: g.team,
          event: "ゴール",
          description: `${g.scorer}がゴール`
        }))
      },
      {
        quarter: 2,
        minute_range: "15-45分",
        quarter_score: calculateQuarterScore(2),
        narrative: `試合のペースが上がり、両チームの狙いが明確になる。${homeTeamName}は${possession > 50 ? "ボール支配を続けながらサイド攻撃を仕掛け" : "奪ったボールからの素早いカウンターを狙い"}、前半を支配。${awayTeamName}は${Math.abs(possession - 50) > 20 ? "ボール奪取後の効果的な攻撃機会を創出" : "同等のペースで試合に食い込む"}。前半終盤に向けて試合の流れが決まりかける重要な15分間。`,
        quarter_summary: `前半の主導権が確立。スコアレスまたは得点シーンが生まれる。`,
        events: getQuarterGoals(2).map(g => ({
          minute: `${g.minute}分`,
          team: g.team,
          event: "ゴール",
          description: `${g.scorer}がゴール`
        }))
      },
      {
        quarter: 3,
        minute_range: "45-60分",
        quarter_score: calculateQuarterScore(3),
        narrative: `後半開始。${awayTeam.attackPower > homeTeam.attackPower ? "アウェイチームが攻撃的なフォーメーション変更で圧力を高める" : "ホームチームが優位を保ちながら攻撃的に出る"}。疲労の影響が出始め、両チームの守備が緩くなる傾向。${prediction.mom || "キープレイヤー"}がこの時間帯で活躍し、試合の流れが大きく変わる可能性。後半序盤の15分が勝敗を左右する。`,
        quarter_summary: `後半の立ち上がりで試合展開が変わる可能性が高い時間帯。`,
        events: getQuarterGoals(3).map(g => ({
          minute: `${g.minute}分`,
          team: g.team,
          event: "ゴール",
          description: `${g.scorer}がゴール`
        }))
      },
      {
        quarter: 4,
        minute_range: "60-90分",
        quarter_score: calculateQuarterScore(4),
        narrative: `試合の終盤。スコアが${prediction.homeScore > prediction.awayScore ? "ホームチーム有利" : prediction.homeScore < prediction.awayScore ? "アウェイチーム有利" : "同点"}の状況で、${prediction.homeScore === prediction.awayScore ? "どちらかが決定的な場面を迎える時間帯" : "リードを守るチームと追うチームの緊迫した攻防"}が展開。${homeTeam.defensePower > 80 && awayTeam.defensePower > 80 ? "両チームの激しい守備が光る" : "スペースを活用した決定的シーン"}が期待される。ロスタイムを含む最後の瞬間まで緊張感が続く。`,
        quarter_summary: `試合の決着がつく。${prediction.homeScore > prediction.awayScore ? "ホームチームが勝利" : prediction.homeScore < prediction.awayScore ? "アウェイチームが勝利" : "戦い続く"}。`,
        events: getQuarterGoals(4).map(g => ({
          minute: `${g.minute}分`,
          team: g.team,
          event: "ゴール",
          description: `${g.scorer}がゴール`
        }))
      }
    ],
    overall_summary: `${homeTeamName}が${awayTeamName}と対戦し、${prediction.homeScore}対${prediction.awayScore}で${prediction.homeScore > prediction.awayScore ? "ホームチーム勝利" : prediction.homeScore < prediction.awayScore ? "アウェイチーム勝利" : "引き分け"}。${possession}%のボール保持率から展開された試合。`,
    key_moments: [
      ...getQuarterGoals(1).map(g => ({
        minute: `${g.minute}分`,
        team: g.team,
        event: "ゴール",
        description: `${g.scorer}がゴール。${g.team}が得点を記録`
      })),
      ...getQuarterGoals(2).map(g => ({
        minute: `${g.minute}分`,
        team: g.team,
        event: "ゴール",
        description: `${g.scorer}がゴール。前半の重要な得点`
      })),
      ...getQuarterGoals(3).map(g => ({
        minute: `${g.minute}分`,
        team: g.team,
        event: "ゴール",
        description: `${g.scorer}がゴール。後半の流れを決定的にした得点`
      })),
      ...getQuarterGoals(4).map(g => ({
        minute: `${g.minute}分`,
        team: g.team,
        event: "ゴール",
        description: `${g.scorer}がゴール。終盤の重要な得点`
      }))
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
    const homeTeamStats = prediction.homeTeam || {};
    const awayTeamStats = prediction.awayTeam || {};
    const possession = Math.round((prediction.possession || 0.5) * 100);
    const goalDetails = (prediction.goals || []).map(g => `${g.minute}分: ${g.scorer} (${g.team})`).join(", ") || "得点なし";

    const prompt = `以下の試合予測データに基づいて、詳細でリアルなクォーター別試合実況を生成してください：

【試合概要】
ホームチーム: ${prediction.homeTeamName || "ホームチーム"}
アウェイチーム: ${prediction.awayTeamName || "アウェイチーム"}
予測最終スコア: ${prediction.homeScore || 0} - ${prediction.awayScore || 0}

【ホームチーム詳細】
- 攻撃力: ${homeTeamStats.attackPower || 80} (0-100スケール)
- 守備力: ${homeTeamStats.defensePower || 80}
- ボール支配率傾向: ${homeTeamStats.ballControl || 50}%
- 攻撃スタイル: ${homeTeamStats.attackPower > 85 ? "積極的な高圧攻撃" : homeTeamStats.attackPower > 70 ? "バランス型の組織的攻撃" : "守備重視のカウンター"}

【アウェイチーム詳細】
- 攻撃力: ${awayTeamStats.attackPower || 80}
- 守備力: ${awayTeamStats.defensePower || 80}
- ボール支配率傾向: ${awayTeamStats.ballControl || 50}%
- 攻撃スタイル: ${awayTeamStats.attackPower > 85 ? "積極的な高圧攻撃" : awayTeamStats.attackPower > 70 ? "バランス型の組織的攻撃" : "守備重視のカウンター"}

【試合統計】
- 全体的なボール保持率: ${possession}% (${possession > 50 ? "ホームチーム優位" : "アウェイチーム優位"})
- ボール保持率の差: ${Math.abs(possession - 50)}ポイント
- 主要な活躍選手: ${prediction.mom || "分散"}
- ゴール情報: ${goalDetails}

【クォーター別の期待パターン】
${possession > 50
  ? `ホームチームがボール支配。前半は優位を保ちながら得点を狙う。アウェイチームはスペースを活用した効果的なカウンター機会を伺う。後半は疲労管理と得点決定力が勝敗を左右。`
  : `アウェイチームのプレッシング戦術が効果的。試合序盤は激しい中盤争い。ホームチームはサイドアタックやロングボールで突破を試みる。後半は相手の疲労をついた攻撃の時間帯が期待される。`}

詳細なクォーター別実況を生成してください。各クォーターで試合の流れが変わることを意識し、実際の試合のように緊張感と劇的性を含めてください。`;

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
