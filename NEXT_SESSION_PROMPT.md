# EPL Match Simulator - プロジェクト引き継ぎドキュメント

## プロジェクト概要
**EPL Match Simulator** は、Flutter Web で開発されたプレミアリーグ試合予測アプリケーションです。チーム統計データに基づいて試合結果をシミュレーションし、スコア、得点者、試合統計、実況コメントを生成します。

## 現在の状態 ✓
- **ステータス**: 正常に動作中
- **デプロイ先**: GitHub Pages → https://columbus0370.github.io/Internal/
- **ブランチ**: `claude/soccer-ai-app-ideas-4ZSuh`
- **最新コミット**: 26b3214 (Remove unused ai_match_analyzer.dart with API implementation)
- **最新確認**: 2026-05-17 (予測ボタンが正常に動作)

## 技術スタック
- **言語**: Dart (Flutter)
- **プラットフォーム**: Flutter Web
- **デプロイ**: GitHub Pages + GitHub Actions
- **ビルドツール**: Flutter 3.24.0
- **HTTP クライアント**: http: ^1.1.0
- **SVG**: flutter_svg: ^2.0.0

## プロジェクト構造
```
/home/user/Internal/
├── .github/
│   └── workflows/
│       └── deploy-flutter-web.yml          # GitHub Actions ワークフロー
├── epl_match_simulator/
│   ├── lib/
│   │   ├── main.dart                       # エントリーポイント
│   │   ├── screens/
│   │   │   ├── splash_screen.dart
│   │   │   ├── team_selection_screen.dart
│   │   │   ├── league_table_screen.dart
│   │   │   └── prediction_result_screen.dart
│   │   ├── services/
│   │   │   ├── prediction_engine.dart          # 予測エンジン（フォールバック）
│   │   │   ├── team_data_loader.dart
│   │   │   ├── match_commentary_generator.dart
│   │   │   └── match_stats_generator.dart
│   │   ├── models/
│   │   │   ├── team.dart
│   │   │   ├── match_prediction.dart
│   │   │   ├── match_commentary.dart
│   │   │   └── match_stats.dart
│   │   └── data/
│   │       └── league_standings.dart
│   ├── assets/
│   │   ├── pl_2025_26_teams.json
│   │   └── emblems/                       # チームロゴ SVG
│   ├── web/
│   │   ├── index.html
│   │   └── manifest.json
│   ├── pubspec.yaml
│   └── README.md
├── .gitignore
└── README.md
```

## 主要機能

### 1. チーム選択 (Team Selection Screen)
- ホームチーム、アウェイチームをドロップダウンから選択
- 選択中のチームの統計情報をリアルタイム表示
  - Overall, Attack, Defense, Ball Control の数値
- **Predict Match** ボタンで予測を生成

### 2. 予測結果表示 (Prediction Result Screen)
結果は3つのタブで表示：

#### Stamen タブ
- サッカーフィールドの図解
- スターティングイレブンの配置
- チーム形成の視覚化

#### Stats タブ
- **⚽ Attack**: ゴール、シュート、シュート精度、xG、ドリブル、コーナー
- **🎯 Possession & Passing**: ポゼッション率、パス数、パス精度
- **🛡️ Defence**: タックル、エアリアルデュエル、ファウル
- **🟨 Discipline**: イエローカード、レッドカード
- **📊 Team Ratings**: 攻撃力、ディフェンス力、ボールコントロール

#### Commentary タブ
- 前半・後半の試合実況
- ドリブル、シュート、セーブ、ファウル、ゴールなどのプレーイベント
- 時系列で順序付け

### 3. リーグテーブル (League Table Screen)
- プレミアリーグの現在のテーブル
- チーム別の勝点、勝敗数、得失点差

## 予測ロジック（PredictionEngine）

### ステップバイステップ

1. **Expected Goals (xG) 計算**
   ```
   xG = 1.5 + (攻撃力 - 相手ディフェンス) / 20
   結果: 0.5 ～ 3.5 の範囲に正規化
   ```

2. **ランダム性の追加（ポアソン分布風）**
   ```
   基本スコア = floor(xG)
   確率 = xG - 基本スコア
   random < 確率 なら +1
   ```

3. **ポゼッション計算**
   ```
   ポゼッション率 = ホームチームのボールコントロール / 合計ボールコントロール
   ```

4. **勝敗確率計算（Elo風）**
   ```
   スコア差に応じて勝敗確率を算出
   合計が 1.0 になるよう正規化
   ```

5. **ゴールイベント生成**
   ```
   スコアの数だけ:
   - ランダムな分（5～90分）を決定
   - FW（フォワード）から得点者を選択
   - アウトフィールドプレイヤーからアシスト者を選択
   ```

## GitHub Actions デプロイワークフロー

**ファイル**: `.github/workflows/deploy-flutter-web.yml`

```yaml
on:
  push:
    branches: [ claude/soccer-ai-app-ideas-4ZSuh ]
    paths:
      - 'epl_match_simulator/**'
      - '.github/workflows/deploy-flutter-web.yml'
  workflow_dispatch:

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      1. Checkout code
      2. Setup Flutter (v3.24.0)
      3. Enable Web
      4. Get dependencies (flutter pub get)
      5. Build Web (--release --web-renderer html --base-href=/Internal/)
      6. Deploy to GitHub Pages (peaceiris/actions-gh-pages@v3)
```

**デプロイ結果**: https://columbus0370.github.io/Internal/

## デプロイ済み環境
- **本番 URL**: https://columbus0370.github.io/Internal/
- **アクセス状態**: ✓ 動作確認済み
- **ブラウザ対応**: Safari（モバイル含む）、Chrome、Firefox

## 既知の制限事項と設計上の選択

### 1. フォールバック解析のみ
- Claude API は統合されていない
- 理由: 環境変数が GitHub Pages では利用不可（セキュリティ）
- 代わりに: ローカルの数学的予測エンジンを使用
- **影響**: 予測は統計ベースだが、十分にランダムで多様

### 2. チームデータの静的読み込み
- チームデータは `pl_2025_26_teams.json` に固定
- リアルタイム更新なし
- **アップデート方法**: JSON ファイルを編集して再ビルド

### 3. モバイル対応
- Flutter Web は自動的にレスポンシブ対応
- Safari（iOS）でテスト済み、正常動作

### 4. オフライン非対応
- アプリはインターネット接続を想定（チームデータ読み込みのため）
- PWA キャッシュの設定は未実装

## 開発時の重要な手順

### ローカルでの実行
```bash
cd /home/user/Internal/epl_match_simulator
flutter pub get
flutter run -d chrome
```

### Web ビルド（本番前）
```bash
cd /home/user/Internal/epl_match_simulator
flutter build web --release --web-renderer html --base-href=/Internal/
```

### ビルド結果確認
```bash
ls -la epl_match_simulator/build/web/
```

## Git ワークフロー

### ブランチ管理
- **開発ブランチ**: `claude/soccer-ai-app-ideas-4ZSuh`
- **本番環境**: このブランチが自動的に GitHub Pages にデプロイされる
- **その他のブランチ**: 実験用（必要に応じて作成）

### コミット規約
```
例: "Fix commentary generation bug"
例: "Add stats tab to prediction result"
例: "Remove unused API implementation code"

形式: [動詞] [対象] [内容]
動詞: Add, Fix, Remove, Update, Refactor, Improve など
```

### 変更のプッシュ
```bash
git add .
git commit -m "Fix prediction button error"
git push -u origin claude/soccer-ai-app-ideas-4ZSuh
```

**自動デプロイ**: push 後、GitHub Actions が自動的に開始
**デプロイ時間**: 約 2-5 分で GitHub Pages に反映

## リセット履歴（参考）
```
26b3214 - Remove unused ai_match_analyzer.dart with API implementation
2284829 - Remove redundant github-pages-deploy.yml
b64cbbc - Fix GitHub Pages deployment workflow
72ca33d - Add GitHub Pages deployment workflow
43d9a0a - Replace AI Analysis tab with Commentary tab
c6adac2 - Remove API key from build and enable fallback analysis
```

このプロジェクトは複数回のイテレーション後、フォールバック解析ベースの安定した実装に収束しています。

## 主要ロジックの位置情報

| 機能 | ファイル | 行番号 |
|------|---------|--------|
| 予測エンジン | `lib/services/prediction_engine.dart` | 全体 |
| 試合実況生成 | `lib/services/match_commentary_generator.dart` | 全体 |
| 試合統計生成 | `lib/services/match_stats_generator.dart` | 全体 |
| チーム選択 UI | `lib/screens/team_selection_screen.dart` | 59-80 (Predict Match ボタン) |
| 予測結果表示 | `lib/screens/prediction_result_screen.dart` | 52-98 (build メソッド) |
| リーグテーブル | `lib/screens/league_table_screen.dart` | 全体 |

## 環境変数とセキュリティ

### 現在の設定
- **API キー**: 設定されていない（環境変数なし）
- **理由**: GitHub Pages 環境では環境変数が利用不可
- **結果**: フォールバック解析のみが実行される（意図的）

### API を統合する場合の注意
- Vercel Serverless Functions や similar サービスを検討
- ただし、セキュリティ（API キー露出）に注意
- クライアント側での API キー管理は避けるべき

## トラブルシューティング

### ワークフローが失敗する場合
1. GitHub Actions のログを確認: リポジトリ → Actions → 最新の実行
2. エラーメッセージを読む（通常は明確）
3. 一般的な原因:
   - Dart/Flutter のバージョン不一致
   - 依存パッケージのダウンロード失敗
   - メモリ不足（ビルド時）

### アプリが起動しない場合
1. ブラウザのコンソールを開く（F12 → Console）
2. エラーメッセージを確認
3. キャッシュをクリアして再読み込み（Ctrl+Shift+Delete）

### チームデータが表示されない場合
1. `assets/pl_2025_26_teams.json` の存在確認
2. pubspec.yaml の assets セクションを確認
3. ローカル実行では `flutter pub get` を実行

## 次のステップ（提案・オプション）

### 短期（1-2 日）
- [ ] CI/CD パイプラインの監視を強化
- [ ] エラーハンドリングの改善（ユーザーフレンドリーなメッセージ）
- [ ] ローディング画面の改善（スピナー → プログレスバー）

### 中期（1-2 週間）
- [ ] Claude API 統合の再検討（セキュリティ満たし方）
- [ ] さらに詳細な試合実況の生成
- [ ] ユーザーインターフェースの UI/UX 改善

### 長期（1-3 ヶ月）
- [ ] チームデータの自動更新機構
- [ ] ユーザーデータ保存（お気に入り試合など）
- [ ] 複数リーグへの拡張
- [ ] 予測精度の統計的分析

## セッション内ルール
このプロジェクトは日本語での開発を想定しています。セッション内での回答は日本語で統一してください。

---

**作成日**: 2026-05-17  
**最終更新**: 2026-05-17  
**プロジェクトステータス**: ✓ 本番環境で動作中
