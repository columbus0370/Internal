# EPL Match Simulator - Claude API 統合完全ガイド（Vercel版）

**対象**: EPL Match Simulator を Vercel で Claude API と統合  
**参考**: CallCue の成功パターンを完全に踏襲  
**目標**: 確実に動作する設計

---

## 🎯 設計の全体像

### アーキテクチャ
```
┌─────────────────────────────────┐
│   Flutter Web (Dart)            │
│   epl_match_simulator           │
├─────────────────────────────────┤
│  HTTP POST /api/analyze-match   │
├─────────────────────────────────┤
│   Vercel Serverless Functions   │
│   (Node.js 20.x)                │
│   - api/analyzeMatch.js         │
│   - CORS 対応                   │
│   - エラーハンドリング          │
├─────────────────────────────────┤
│   Claude API (Anthropic)        │
│   - API キーはサーバーのみ      │
│   - クライアントに露出なし      │
└─────────────────────────────────┘
```

### ホスティング構成
```
GitHub リポジトリ
    ↓
    ├─ epl_match_simulator/ (Flutter Web)
    │   └─ flutter build web → build/web/
    │
    ├─ api/ (Serverless Functions)
    │   └─ analyzeMatch.js
    │
    ├─ vercel.json (Vercel 設定)
    ├─ package.json (npm 設定)
    └─ vercel-build.sh (ビルドスクリプト)
    
Vercel (自動デプロイ)
    ├─ Flutter Web アプリ
    └─ Serverless Function
    
URL: https://epl-match-simulator.vercel.app/
```

---

## 📋 実装手順

### フェーズ 1: プロジェクト構造の準備

#### ステップ 1-1: Vercel 設定ファイルを作成

**ファイル**: `/home/user/Internal/vercel.json`

```json
{
  "version": 2,
  "buildCommand": "npm run vercel-build",
  "outputDirectory": "build/web",
  "functions": {
    "api/analyzeMatch.js": {
      "maxDuration": 60
    }
  },
  "rewrites": [
    {
      "source": "/((?!api).*)",
      "destination": "/index.html"
    }
  ]
}
```

**説明**:
| キー | 値 | 役割 |
|------|-----|------|
| buildCommand | `npm run vercel-build` | npm スクリプト経由でビルド |
| outputDirectory | `build/web` | Flutter ビルド出力 |
| functions | analyzeMatch.js | Serverless Function メタデータ |
| maxDuration | 60 | 実行時間制限 60秒 |
| rewrites | SPA ルーティング | /api 以外は index.html へ |

#### ステップ 1-2: npm 設定ファイルを作成

**ファイル**: `/home/user/Internal/package.json`

```json
{
  "name": "epl-match-simulator",
  "version": "1.0.0",
  "description": "EPL Match Simulator with Claude API integration",
  "private": true,
  "engines": {
    "node": "20.x"
  },
  "scripts": {
    "vercel-build": "bash ./vercel-build.sh"
  }
}
```

#### ステップ 1-3: ビルドスクリプトを作成

**ファイル**: `/home/user/Internal/vercel-build.sh`

```bash
#!/bin/bash
set -e

echo "=== EPL Match Simulator - Vercel Build ==="

# Flutter SDK をダウンロード（キャッシュ済みならスキップ）
if [ ! -d "_flutter" ]; then
  echo "[1/6] Downloading Flutter SDK..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable _flutter
else
  echo "[1/6] Using cached Flutter SDK"
fi

# パスを追加
export PATH="$PATH:$(pwd)/_flutter/bin"

# Flutter のセットアップ
echo "[2/6] Setting up Flutter..."
flutter --version
flutter config --no-analytics
flutter precache --web

# 依存関係取得
echo "[3/6] Getting Dart dependencies..."
cd epl_match_simulator
flutter pub get

# Web ビルド
echo "[4/6] Building Flutter Web (Release)..."
flutter build web --release --web-renderer html --base-href=/

echo "[5/6] Build completed!"
cd ..

# ビルド出力確認
echo "[6/6] Verifying build output..."
if [ -d "build/web" ]; then
  echo "✓ build/web directory found"
  ls -lh build/web/ | head -10
else
  echo "✗ ERROR: build/web not found!"
  exit 1
fi

echo "=== Build completed successfully! ==="
```

**ポイント**:
- `set -e`: エラーで即座に停止
- `_flutter` ディレクトリチェック: 2回目以降のビルドが高速化
- `flutter precache --web`: Web 最適化
- `--web-renderer html`: 互換性最大化
- ビルド出力の確認

---

### フェーズ 2: Serverless Function の実装

#### ステップ 2-1: API エンドポイントを作成

**ファイル**: `/home/user/Internal/api/analyzeMatch.js`

```javascript
const CLAUDE_MODEL = "claude-sonnet-4-6";
const CLAUDE_ENDPOINT = "https://api.anthropic.com/v1/messages";
const ANTHROPIC_VERSION = "2024-06-01";

const SYSTEM_PROMPT = `あなたはプレミアリーグの専門家です。
試合予測データを分析し、日本語で詳細な試合分析とコメントを生成してください。

以下の情報に基づいて分析してください：
- チーム統計（攻撃力、ディフェンス力、ボールコントロール）
- 予測スコア
- 得点者情報

実況的なコメント、戦術分析、両チームの強みと弱みを含めてください。`;

/**
 * Vercel Serverless Function
 * Claude API のプロキシ
 * 
 * リクエスト:
 *   POST /api/analyzeMatch
 *   { "prediction": {...} }
 * 
 * レスポンス:
 *   { "success": true, "analysis": "..." }
 */
module.exports = async (req, res) => {
  // ============================================
  // 1. CORS ヘッダー設定
  // ============================================
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  // ============================================
  // 2. プリフライトリクエスト対応
  // ============================================
  if (req.method === "OPTIONS") {
    return res.status(200).end();
  }

  // ============================================
  // 3. HTTP メソッド検証
  // ============================================
  if (req.method !== "POST") {
    return res.status(405).json({
      success: false,
      error: "Method not allowed. Use POST.",
    });
  }

  // ============================================
  // 4. API キー確認
  // ============================================
  const apiKey = process.env.CLAUDE_API_KEY;

  if (!apiKey) {
    console.error("CLAUDE_API_KEY environment variable not set");
    return res.status(500).json({
      success: false,
      error: "Server configuration error: CLAUDE_API_KEY not set",
    });
  }

  // ============================================
  // 5. リクエストボディ検証
  // ============================================
  let prediction;

  try {
    prediction = req.body?.prediction;

    if (!prediction) {
      return res.status(400).json({
        success: false,
        error: "Missing 'prediction' field in request body",
      });
    }

    if (typeof prediction !== "object") {
      return res.status(400).json({
        success: false,
        error: "'prediction' must be an object",
      });
    }
  } catch (err) {
    return res.status(400).json({
      success: false,
      error: `Invalid request body: ${err.message}`,
    });
  }

  // ============================================
  // 6. Claude API へのリクエスト
  // ============================================
  try {
    console.log("[API] Calling Claude API...");

    const userMessage = `
以下の試合予測データを分析してください：

ホームチーム: ${prediction.homeTeamName}
アウェイチーム: ${prediction.awayTeamName}
予測スコア: ${prediction.homeScore} - ${prediction.awayScore}

ホームチーム統計:
- 攻撃力: ${prediction.homeTeam?.attackPower || "N/A"}
- ディフェンス: ${prediction.homeTeam?.defensePower || "N/A"}
- ボールコントロール: ${prediction.homeTeam?.ballControl || "N/A"}

アウェイチーム統計:
- 攻撃力: ${prediction.awayTeam?.attackPower || "N/A"}
- ディフェンス: ${prediction.awayTeam?.defensePower || "N/A"}
- ボールコントロール: ${prediction.awayTeam?.ballControl || "N/A"}

得点者: ${
      prediction.goals && prediction.goals.length > 0
        ? prediction.goals.map((g) => `${g.minute}: ${g.scorer}`).join(", ")
        : "なし"
    }
ポゼッション: ${prediction.possession ? (prediction.possession * 100).toFixed(1) : "N/A"}%
マン・オブ・ザ・マッチ: ${prediction.mom || "N/A"}

詳細な試合分析と実況コメントを生成してください。`;

    const response = await fetch(CLAUDE_ENDPOINT, {
      method: "POST",
      headers: {
        "x-api-key": apiKey,
        "anthropic-version": ANTHROPIC_VERSION,
        "content-type": "application/json",
      },
      body: JSON.stringify({
        model: CLAUDE_MODEL,
        max_tokens: 1024,
        system: SYSTEM_PROMPT,
        messages: [
          {
            role: "user",
            content: userMessage,
          },
        ],
      }),
    });

    const data = await response.json();

    // ============================================
    // 7. Claude API レスポンス検証
    // ============================================
    if (!response.ok) {
      console.error("[API] Claude API error:", data);
      return res.status(response.status).json({
        success: false,
        error: `Claude API error (${response.status}): ${
          data.error?.message || JSON.stringify(data)
        }`,
      });
    }

    const analysisText = data?.content?.[0]?.text;

    if (!analysisText) {
      console.error("[API] Empty response from Claude:", data);
      return res.status(500).json({
        success: false,
        error: "Empty response from Claude API",
      });
    }

    console.log("[API] Claude API success");

    // ============================================
    // 8. 正常なレスポンス
    // ============================================
    return res.status(200).json({
      success: true,
      analysis: analysisText,
    });
  } catch (err) {
    console.error("[API] Request failed:", err);
    return res.status(500).json({
      success: false,
      error: `Request failed: ${err.message}`,
    });
  }
};
```

**実装のポイント**:

| セクション | 役割 |
|-----------|------|
| CORS ヘッダー | Flutter Web からのクロスオリジンリクエストに対応 |
| OPTIONS 対応 | CORS プリフライトリクエストに対応 |
| メソッド検証 | POST 以外は 405 エラー |
| API キー確認 | 環境変数から API キーを読み込み |
| リクエスト検証 | prediction フィールドの存在と形式を確認 |
| Claude API 呼び出し | 正しいヘッダーとボディを送信 |
| レスポンス検証 | 空レスポンス、エラーをチェック |
| エラーハンドリング | 各ステップで詳細なエラーメッセージを返す |

---

### フェーズ 3: Flutter クライアント側の実装

#### ステップ 3-1: HTTP サービスを作成

**ファイル**: `/home/user/Internal/epl_match_simulator/lib/services/match_analysis_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/match_prediction.dart';

class MatchAnalysisService {
  /// Claude API を使用して試合分析を生成
  /// 
  /// リクエスト: POST /api/analyzeMatch
  /// リクエストボディ: { "prediction": {...} }
  /// 
  /// レスポンス: { "success": true, "analysis": "..." }
  static Future<String> analyzeMatch(MatchPrediction prediction) async {
    try {
      // ============================================
      // 1. API エンドポイント決定
      // ============================================
      final apiUrl = _getApiUrl();
      print('[MatchAnalysis] API URL: $apiUrl');

      // ============================================
      // 2. リクエスト作成
      // ============================================
      final requestBody = {
        'prediction': {
          'homeTeamName': prediction.homeTeamName,
          'awayTeamName': prediction.awayTeamName,
          'homeScore': prediction.homeScore,
          'awayScore': prediction.awayScore,
          'homeTeam': {
            'attackPower': prediction.homeTeam.attackPower,
            'defensePower': prediction.homeTeam.defensePower,
            'ballControl': prediction.homeTeam.ballControl,
          },
          'awayTeam': {
            'attackPower': prediction.awayTeam.attackPower,
            'defensePower': prediction.awayTeam.defensePower,
            'ballControl': prediction.awayTeam.ballControl,
          },
          'possession': prediction.possession,
          'mom': prediction.mom,
          'goals': prediction.goals
              .map((g) => {
                    'minute': g.minute,
                    'scorer': g.scorer,
                    'team': g.team,
                    'assist': g.assist,
                  })
              .toList(),
        },
      };

      print('[MatchAnalysis] Sending request...');

      // ============================================
      // 3. HTTP リクエスト送信
      // ============================================
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () =>
                throw Exception('API request timeout (60 seconds)'),
          );

      print('[MatchAnalysis] Response status: ${response.statusCode}');

      // ============================================
      // 4. レスポンス検証
      // ============================================
      if (response.statusCode != 200) {
        print('[MatchAnalysis] API error: ${response.body}');
        throw Exception(
          'API error: status ${response.statusCode}, body: ${response.body}',
        );
      }

      // ============================================
      // 5. JSON パース
      // ============================================
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['success'] != true) {
        throw Exception('API returned error: ${data['error']}');
      }

      final analysis = data['analysis'] as String?;

      if (analysis == null || analysis.isEmpty) {
        throw Exception('Empty analysis from API');
      }

      print('[MatchAnalysis] Analysis received (${analysis.length} chars)');
      return analysis;
    } on Exception catch (e) {
      print('[MatchAnalysis] Error: $e');
      // フォールバック解析に切り替え
      return _generateFallbackAnalysis(prediction);
    }
  }

  /// API URL を決定（環境に応じて変更）
  static String _getApiUrl() {
    // ローカル開発: http://localhost:3000/api/analyzeMatch
    // 本番 Vercel: https://epl-match-simulator.vercel.app/api/analyzeMatch
    // 相対パス: /api/analyzeMatch
    
    const isDevelopment = bool.fromEnvironment('DEVELOPMENT', defaultValue: false);
    
    if (isDevelopment) {
      // ローカル開発用（ローカルサーバーを起動している場合）
      return 'http://localhost:3000/api/analyzeMatch';
    }
    
    // 本番環境（Vercel）または相対パス
    return '/api/analyzeMatch';
  }

  /// フォールバック解析（API が使用できない場合）
  static String _generateFallbackAnalysis(MatchPrediction prediction) {
    final scoreGap = (prediction.homeScore - prediction.awayScore).abs();
    final homeTeam = prediction.homeTeamName;
    final awayTeam = prediction.awayTeamName;

    final analyses = <String>[];

    // 試合結果分析
    if (scoreGap == 0) {
      analyses.add(
        '**${homeTeam} vs ${awayTeam}: ${prediction.homeScore}-${prediction.awayScore} (同点)**\n'
        'この試合は両チームが互角の戦いを繰り広げ、同点に終わりました。'
        '前半から後半までを通じて、両チームとも全力を尽くし、'
        'どちらかが決定的なアドバンテージを得られませんでした。',
      );
    } else if (prediction.homeScore > prediction.awayScore) {
      analyses.add(
        '**${homeTeam} vs ${awayTeam}: ${prediction.homeScore}-${prediction.awayScore} (${homeTeam}勝利)**\n'
        '${homeTeam}が見事な勝利を手にしました。ホームの利を活かし、'
        '攻撃的なプレーで${awayTeam}を圧倒。${scoreGap}点の差で制しました。',
      );
    } else {
      analyses.add(
        '**${homeTeam} vs ${awayTeam}: ${prediction.homeScore}-${prediction.awayScore} (${awayTeam}勝利)**\n'
        '${awayTeam}がアウェイでの困難な環境を克服し、'
        '立派な勝利を収めました。${homeTeam}の本拠地での${scoreGap}点の逆転勝利は素晴らしい成果です。',
      );
    }

    // ポゼッション分析
    final homePoss = (prediction.possession * 100).toStringAsFixed(1);
    final awayPoss = (100 - double.parse(homePoss)).toStringAsFixed(1);
    analyses.add(
      '**ポゼッション分析**\n'
      '${homeTeam}がボールを支配し、${homePoss}%のポゼッション率を記録しました。'
      '一方の${awayTeam}は${awayPoss}%に留まり、守備的なアプローチで試合に臨みました。',
    );

    // マン・オブ・ザ・マッチ
    analyses.add(
      '**マン・オブ・ザ・マッチ**\n'
      '${prediction.mom}が試合を通じて素晴らしいパフォーマンスを展開しました。'
      '攻防両面での活躍が目立ち、チームの勝利に大きく貢献しました。',
    );

    return analyses.join('\n\n');
  }
}
```

**実装のポイント**:
- API URL は環境に応じて切り替え可能
- タイムアウト設定（60秒）
- 詳細なログ出力
- エラーハンドリングとフォールバック

#### ステップ 3-2: Commentary タブを改修

**ファイル**: `/home/user/Internal/epl_match_simulator/lib/screens/prediction_result_screen.dart`

Commentary タブを以下に変更：

```dart
Widget _buildCommentaryTab() {
  return FutureBuilder<String>(
    future: MatchAnalysisService.analyzeMatch(widget.prediction),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.deepPurple),
              SizedBox(height: 16),
              Text('試合分析を生成中...'),
            ],
          ),
        );
      }

      if (snapshot.hasError) {
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠️ 分析エラー',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'AI 分析が利用できないため、フォールバック解析を表示します。',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 16),
                Text(snapshot.data ?? '分析内容'),
              ],
            ),
          ),
        );
      }

      final analysis = snapshot.data ?? '';

      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🤖 AI 試合分析',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  analysis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      );
    },
  );
}
```

---

### フェーズ 4: Vercel デプロイ設定

#### ステップ 4-1: Vercel CLI で初期化

```bash
cd /home/user/Internal
vercel login
vercel
```

プロンプトで以下のように回答：
```
? Set up and deploy "~/Internal"? yes
? Which scope do you want to deploy to? (your account)
? Link to existing project? no
? What's your project's name? epl-match-simulator
? In which directory is your code located? ./
```

#### ステップ 4-2: 環境変数を設定

```bash
vercel env add CLAUDE_API_KEY
# プロンプトで API キーを入力
# 対象環境: Production, Preview, Development にすべてチェック
```

確認:
```bash
vercel env ls
```

---

### フェーズ 5: ローカルテスト

#### ステップ 5-1: Vercel Functions をローカルでテスト

```bash
vercel dev
```

コマンド実行で：
```
> Ready! Available at http://localhost:3000
```

ブラウザで http://localhost:3000 にアクセス

#### ステップ 5-2: API をテスト

PowerShell でテスト:
```powershell
$body = @{
  prediction = @{
    homeTeamName = "Manchester City"
    awayTeamName = "Liverpool"
    homeScore = 2
    awayScore = 1
    homeTeam = @{
      attackPower = 95
      defensePower = 93
      ballControl = 86
    }
    awayTeam = @{
      attackPower = 92
      defensePower = 88
      ballControl = 85
    }
    possession = 0.55
    mom = "Haaland"
    goals = @()
  }
} | ConvertTo-Json

Invoke-RestMethod `
  -Uri "http://localhost:3000/api/analyzeMatch" `
  -Method POST `
  -Body $body `
  -ContentType "application/json" | ConvertTo-Json
```

期待される レスポンス:
```json
{
  "success": true,
  "analysis": "試合分析のテキスト..."
}
```

---

### フェーズ 6: 本番デプロイ

#### ステップ 6-1: Git にコミット

```bash
git add vercel.json package.json vercel-build.sh api/ epl_match_simulator/
git commit -m "Add Claude API integration with Vercel Serverless Functions"
git push origin claude/soccer-ai-app-ideas-4ZSuh
```

#### ステップ 6-2: Vercel が自動的にデプロイ

GitHub push が検知されて、Vercel が自動的にビルド・デプロイを開始

デプロイ完了後のアクセス先:
```
https://epl-match-simulator.vercel.app/
```

---

## 🔧 トラブルシューティング

### 問題 1: "API key not configured" エラー

```
原因: CLAUDE_API_KEY が設定されていない

解決:
$ vercel env add CLAUDE_API_KEY
$ vercel deploy --prod
```

### 問題 2: CORS エラーが出る

```
原因: API ヘッダーが不足

確認: api/analyzeMatch.js に CORS ヘッダーが設定されているか
res.setHeader("Access-Control-Allow-Origin", "*");
res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
res.setHeader("Access-Control-Allow-Headers", "Content-Type");
```

### 問題 3: "/api/analyzeMatch" に接続できない

```
ローカル開発:
- vercel dev が起動しているか確認
- ブラウザコンソールで Network タブを確認

本番:
- Vercel の Logs をチェック
- vercel logs コマンドで確認
```

### 問題 4: Flutter ビルドが失敗

```
原因: Flutter SDK のダウンロード失敗

解決:
- Vercel のビルドログを確認
- git clone が成功しているか確認
- _flutter ディレクトリの削除を試す（キャッシュクリア）
```

---

## 📊 本番環境チェックリスト

デプロイ前の確認事項:

- [ ] `vercel.json` に Serverless Function が定義されている
- [ ] `package.json` に `vercel-build` スクリプトがある
- [ ] `vercel-build.sh` が実行可能（`chmod +x vercel-build.sh`）
- [ ] `api/analyzeMatch.js` に CORS ヘッダーがある
- [ ] `process.env.CLAUDE_API_KEY` を読み込んでいる
- [ ] `vercel env add CLAUDE_API_KEY` で API キーを設定した
- [ ] ローカルの `vercel dev` でテスト済み
- [ ] API エンドポイント `/api/analyzeMatch` が応答する
- [ ] Flutter から `/api/analyzeMatch` に POST できる
- [ ] エラーハンドリングが詳細

---

## 🚀 デプロイ後のアクセス

```
Web アプリ:
https://epl-match-simulator.vercel.app/

API エンドポイント:
https://epl-match-simulator.vercel.app/api/analyzeMatch

Vercel ダッシュボード:
https://vercel.com/columbus0370s-projects/epl-match-simulator

Vercel ログ:
$ vercel logs
```

---

## 💡 将来の拡張

このアーキテクチャなら、以下の機能を簡単に追加できます：

### 追加機能例 1: チームデータの AI 分析

```javascript
// api/analyzeTeam.js
module.exports = async (req, res) => {
  const { team } = req.body;
  const response = await fetch(CLAUDE_ENDPOINT, {
    // ...Claude API 呼び出し
  });
  // ...
};
```

### 追加機能例 2: ユーザーフィードバック学習

```javascript
// api/saveFeedback.js
module.exports = async (req, res) => {
  const { prediction, actualResult, feedback } = req.body;
  // Firebase / Supabase に保存
  // 将来の精度向上に使用
};
```

### 追加機能例 3: 複数 LLM のサポート

```javascript
// api/analyzeMatch.js の拡張
const LLM_PROVIDER = process.env.LLM_PROVIDER || 'claude'; // claude, gpt4, など

if (LLM_PROVIDER === 'claude') {
  // Claude API
} else if (LLM_PROVIDER === 'gpt4') {
  // OpenAI GPT-4
}
```

---

**作成**: 2026-05-18  
**対象**: EPL Match Simulator × Vercel × Claude API  
**パターン**: CallCue 成功例を完全踏襲
