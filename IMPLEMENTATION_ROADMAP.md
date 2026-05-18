# Claude API 統合 - フェーズ別実装ロードマップ

**開始日**: 2026-05-18  
**目標**: Claude API を Vercel で動作させる（CallCue パターン）  
**総フェーズ**: 6 フェーズ

---

## 🗓️ フェーズ概要

```
┌─────────────────────────────────────────────────────────┐
│ Phase 1: 設定ファイル作成                                │
│ 所要時間: 5分 | Claude Code: 100% | ユーザー: 0%        │
│ 内容: vercel.json, package.json, vercel-build.sh       │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│ Phase 2: Serverless Function 実装                       │
│ 所要時間: 5分 | Claude Code: 100% | ユーザー: 0%        │
│ 内容: api/analyzeMatch.js を作成                       │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│ Phase 3: Flutter クライアント改修                        │
│ 所要時間: 10分 | Claude Code: 100% | ユーザー: 0%       │
│ 内容: MatchAnalysisService + Commentary タブ修正        │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│ Phase 4: ローカルテスト                                  │
│ 所要時間: 10分 | Claude Code: 0% | ユーザー: 100%       │
│ 内容: vercel dev + API テスト                          │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│ Phase 5: Vercel 環境設定                                │
│ 所要時間: 5分 | Claude Code: 0% | ユーザー: 100%        │
│ 内容: vercel login + CLAUDE_API_KEY 登録               │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│ Phase 6: 本番デプロイ                                    │
│ 所要時間: 15分 | Claude Code: 50% | ユーザー: 50%       │
│ 内容: Git commit + push                                 │
└─────────────────────────────────────────────────────────┘
```

---

## 📋 各フェーズの詳細

### Phase 1: 設定ファイル作成

**🎯 目標**
```
作成ファイル:
✓ /home/user/Internal/vercel.json
✓ /home/user/Internal/package.json
✓ /home/user/Internal/vercel-build.sh
```

**✅ Claude Code で実行**
- 3 つのファイルを自動作成
- 内容は完全に記述されている
- ユーザーは何もしない

**⚠️ ユーザー確認項目**
```
実行後に確認すること:
□ 3 つのファイルが作成されたか
□ vercel-build.sh が実行可能か（ls -la で確認）
```

**準備完了後**: Phase 2 に進む

---

### Phase 2: Serverless Function 実装

**🎯 目標**
```
作成ファイル:
✓ /home/user/Internal/api/analyzeMatch.js (196 行)
```

**✅ Claude Code で実行**
- api/ ディレクトリを作成
- analyzeMatch.js を完全に実装
- CORS ヘッダー、エラーハンドリング等すべて含む

**⚠️ ユーザー確認項目**
```
実行後に確認すること:
□ api/analyzeMatch.js が作成されたか
□ ファイルが UTF-8 で保存されているか
□ シンタックスエラーがないか（手動確認不要）
```

**準備完了後**: Phase 3 に進む

---

### Phase 3: Flutter クライアント改修

**🎯 目標**
```
作成・改修ファイル:
✓ /home/user/Internal/epl_match_simulator/lib/services/match_analysis_service.dart (新規)
✓ /home/user/Internal/epl_match_simulator/lib/screens/prediction_result_screen.dart (修正)
```

**✅ Claude Code で実行**
- MatchAnalysisService を新規作成（HTTP クライアント）
- prediction_result_screen.dart の Commentary タブを FutureBuilder に改修
- エラーハンドリング、フォールバック解析も実装

**⚠️ ユーザー確認項目**
```
実行後に確認すること:
□ 2 つのファイルが作成・改修されたか
□ pubspec.yaml に http パッケージが既に存在するか
  （確認: grep "http:" pubspec.yaml）
```

**準備完了後**: Phase 4 に進む

---

### Phase 4: ローカルテスト

**🎯 目標**
```
確認項目:
✓ vercel dev が起動する
✓ Flutter Web がブラウザで表示される
✓ API エンドポイント /api/analyzeMatch に POST できる
```

**❌ Claude Code では実行不可**
（ローカルマシンの環境で実行する必要があります）

**👤 ユーザーが実行すべき手順**

#### 4-1: Vercel CLI をインストール（初回のみ）
```bash
npm install -g vercel
```

#### 4-2: ローカルサーバーを起動
```bash
cd /home/user/Internal
vercel dev
```

**期待される出力**:
```
> Ready! Available at http://localhost:3000
```

#### 4-3: ブラウザで確認
```
http://localhost:3000 にアクセス
→ Flutter Web アプリが表示される
```

#### 4-4: API をテスト
PowerShell で以下を実行:

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

**期待される レスポンス**:
```json
{
  "success": true,
  "analysis": "試合分析のテキスト..."
}
```

**⚠️ 注意事項**
```
- API キーを設定していないため、エラーが返される可能性あり
  → これは正常（Phase 5 で設定します）
- フォールバック解析が返される場合もあります
```

**トラブルシューティング**
| 症状 | 原因 | 解決策 |
|------|------|--------|
| `Port 3000 is already in use` | 別プロセスが使用中 | `lsof -i :3000` で確認、Kill |
| `CORS error` | API ヘッダーエラー | Phase 2 のコードを確認 |
| `404 /api/analyzeMatch` | Function ファイル位置エラー | `ls -la api/analyzeMatch.js` で確認 |

**準備完了後**: Phase 5 に進む

---

### Phase 5: Vercel 環境設定

**🎯 目標**
```
実施項目:
✓ Vercel にログイン
✓ CLAUDE_API_KEY 環境変数を登録
✓ API キーが正しく読み込まれることを確認
```

**❌ Claude Code では実行不可**
（Vercel ダッシュボード or Vercel CLI でしか実行できません）

**👤 ユーザーが実行すべき手順**

#### 5-1: Vercel にログイン
```bash
vercel login
```

ブラウザで Vercel アカウントにログイン

#### 5-2: Claude API キーを環境変数として登録
```bash
vercel env add CLAUDE_API_KEY
```

プロンプト:
```
? What's the value of CLAUDE_API_KEY? 
→ API キーを入力（貼り付け）

? Add CLAUDE_API_KEY to which Environments (select multiple)?
→ Production, Preview, Development すべてチェック
```

#### 5-3: 登録確認
```bash
vercel env ls
```

出力:
```
> Vercel CLI 33.x.x
> Environment Variables for project epl-match-simulator

Production
  ✓ CLAUDE_API_KEY

Preview
  ✓ CLAUDE_API_KEY

Development
  ✓ CLAUDE_API_KEY
```

**⚠️ API キーの取得方法**
```
まだ持っていない場合:
1. https://console.anthropic.com にアクセス
2. APIキーを生成
3. コピーして貼り付け
```

**準備完了後**: Phase 6 に進む

---

### Phase 6: 本番デプロイ

**🎯 目標**
```
実施項目:
✓ すべての新規ファイルを Git にコミット
✓ GitHub に push
✓ Vercel が自動的にビルド・デプロイ
```

**✅ Claude Code で実行（部分）**
- 全ファイルを staging
- コミットメッセージを作成
- git commit を実行

**👤 ユーザーが実行（部分）**
- git push

#### 6-1: Claude Code が実行すること
```bash
git add vercel.json package.json vercel-build.sh
git add api/analyzeMatch.js
git add epl_match_simulator/lib/services/match_analysis_service.dart
git add epl_match_simulator/lib/screens/prediction_result_screen.dart

git commit -m "Implement Claude API integration with Vercel Serverless Functions

- Add vercel.json, package.json, vercel-build.sh for Vercel deployment
- Implement api/analyzeMatch.js Serverless Function with Claude API
- Create MatchAnalysisService for HTTP communication
- Refactor Commentary tab to use FutureBuilder for AI analysis
- Include error handling and fallback analysis"

git log --oneline -3  # 確認用
```

#### 6-2: ユーザーが実行すること
```bash
git push origin claude/soccer-ai-app-ideas-4ZSuh
```

**期待される出力**:
```
Enumerating objects: ...
Counting objects: ...
...
To http://127.0.0.1:xxxxx/git/columbus0370/Internal
   xxxxxxx..xxxxxxx  claude/soccer-ai-app-ideas-4ZSuh -> claude/soccer-ai-app-ideas-4ZSuh
```

#### 6-3: Vercel が自動デプロイ
GitHub push が検知されると、Vercel が自動的に：
```
1. ビルド開始（~3-5 分）
2. Serverless Function をデプロイ
3. Flutter Web をビルド・デプロイ
```

**デプロイ完了を確認**:
```
https://epl-match-simulator.vercel.app/
（自動割り当てされるドメイン）
```

**または**:
```bash
vercel ls
# epl-match-simulator プロジェクトの URL を確認
```

**本番テスト**:
```
1. ブラウザで https://epl-match-simulator.vercel.app/ にアクセス
2. チーム選択 → Predict Match をクリック
3. Commentary タブで "🤖 AI 試合分析" が表示される
4. テキストが Claude から生成されていることを確認
```

**⚠️ 注意事項**
```
- 初回ビルドは 3-5 分かかります
- 2 回目以降のビルドは 1-2 分で完了（キャッシュ）
- ビルドログは Vercel ダッシュボードで確認可能
```

**準備完了**: 本番環境での Claude API 統合が完了！

---

## 🎯 実行フロー（クイックリファレンス）

### Claude Code で実行する部分
```
[ Phase 1 ] 設定ファイル作成
  ↓
[ Phase 2 ] Serverless Function 実装
  ↓
[ Phase 3 ] Flutter クライアント改修
  ↓
[ Phase 6-1 ] Git commit
```

### ユーザーが実行する部分
```
[ Phase 4 ] ローカルテスト
  - vercel dev
  - API テスト
  ↓
[ Phase 5 ] Vercel 環境設定
  - vercel login
  - vercel env add CLAUDE_API_KEY
  ↓
[ Phase 6-2 ] git push
```

---

## 📊 所要時間目安

| フェーズ | Claude Code | ユーザー | 合計 | 累計 |
|---------|-----------|---------|------|------|
| 1 | 5分 | - | 5分 | 5分 |
| 2 | 5分 | - | 5分 | 10分 |
| 3 | 10分 | - | 10分 | 20分 |
| 4 | - | 10分 | 10分 | 30分 |
| 5 | - | 5分 | 5分 | 35分 |
| 6 | 3分 | 2分 | 5分 | 40分 |

**総所要時間**: 約 40 分（ビルド待機時間含む）

---

## ✅ フェーズの進め方

各フェーズで以下のステップを繰り返します：

```
1. フェーズの詳細を確認
2. 「Claude Code で実行」セクションで実施
3. 「ユーザー確認項目」をチェック
4. 問題なければ次のフェーズへ
```

---

## 🚨 トラブルシューティング全般

| 問題 | チェックポイント | 次のアクション |
|------|-----------------|---------------|
| ファイルが作成されない | Phase 1-3 のコマンド実行を確認 | Claude Code に再実行を依頼 |
| ローカルテストで 404 | api/analyzeMatch.js の場所 | `ls api/analyzeMatch.js` で確認 |
| API キー エラー | Phase 5 で CLAUDE_API_KEY を設定したか | `vercel env ls` で確認 |
| Vercel デプロイ失敗 | ビルドログを確認 | vercel ダッシュボードで Deployments を確認 |
| CORS エラー | api/analyzeMatch.js のヘッダー設定 | Phase 2 のコードを確認 |

---

**準備完了**！ 

各フェーズの実行を開始してください。  
次のメッセージで「Phase 1 を開始」と入力すると、実装を開始します。

