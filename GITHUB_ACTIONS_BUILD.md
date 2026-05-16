# GitHub Actions による自動ビルド戦略

## 概要

このブランチ（`claude/vercel-dynamic-build`）は、GitHub Actions を使用して Flutter Web ビルドを自動生成し、生成物を git に自動コミットします。

## 動作フロー

```
1. コード変更を push
   ↓
2. GitHub Actions トリガー
   ↓
3. Flutter ビルド実行 (ubuntu-latest)
   ↓
4. build/web を自動コミット & push
   ↓
5. Vercel 自動デプロイ (build/web から)
```

## ワークフロー詳細

**ファイル**: `.github/workflows/flutter-web-build.yml`

### トリガー条件

以下の場合に GitHub Actions が実行されます：

- `claude/vercel-dynamic-build` ブランチへのプッシュ
- 以下ファイルの変更：
  - `epl_match_simulator/**`
  - `pubspec.yaml`
  - `.github/workflows/flutter-web-build.yml`
- 手動実行（`workflow_dispatch`）

### 実行内容

1. **checkout**: コードをクローン
2. **Flutter セットアップ**: バージョン 3.24.0、キャッシング有効
3. **依存関係取得**: `flutter pub get`
4. **ビルド実行**: `flutter build web --release`
5. **検証**: build/web が生成されたか確認
6. **自動コミット**: build/web を git にコミット & プッシュ

### ビルド実行時間

- **初回**: 3-5分（Flutter SDK キャッシュ構築）
- **2回目以降**: 1-2分（キャッシング活用）

## セットアップ手順

### 1️⃣ このブランチで動作確認

```bash
# 現在のブランチ確認
git branch -v
# claude/vercel-dynamic-build が表示されればOK
```

### 2️⃣ 最初のビルドをトリガー

```bash
# 何か変更を加えて push する
echo "# Test comment" >> epl_match_simulator/lib/main.dart
git add epl_match_simulator/lib/main.dart
git commit -m "Trigger GitHub Actions build"
git push origin claude/vercel-dynamic-build
```

### 3️⃣ GitHub Actions 実行確認

GitHub リポジトリ → **Actions** タブ で実行状況を確認：

- ✅ 緑チェック: ビルド成功
- ❌ 赤×: ビルド失敗（ログで原因確認）

### 4️⃣ コミット確認

ビルド成功後、自動生成されたコミットが push されます：

```bash
git log --oneline
# "Auto-generated: Flutter Web build artifacts" というコミットが表示される
```

## API 動作確認（スマホ Safari）

### テスト手順

1. **Vercel デプロイ URL にアクセス**
   ```
   https://your-vercel-app.vercel.app
   ```

2. **API テスト用チェックリスト**
   - [ ] ホーム画面が読み込まれる
   - [ ] 「Predict a Match」ボタンが表示される
   - [ ] ボタンをタップ → チーム選択画面が表示される
   - [ ] チーム選択 → マッチ予測開始
   - [ ] ローディング画面が表示される
   - [ ] 予測結果が表示される
   - [ ] API が正常に応答（ネットワークエラーなし）

3. **Safari Developer Tools で確認**（iOS デバイスで）
   - Mac に接続して Safari Developer Tools を開く
   - Console でエラー確認
   - Network タブで `/api/predictMatch` への POST リクエストを確認

## トラブルシューティング

### GitHub Actions ビルド失敗

**症状**: ❌ ビルドが失敗

**原因と対応**:

```yaml
1. Flutter pub get エラー
   → pubspec.yaml の依存関係を確認
   → 互換性のあるバージョン指定

2. Flutter build web エラー
   → コンパイルエラーをログで確認
   → ローカルで flutter build web --release を実行
   → エラーを修正してから push

3. タイムアウト
   → GitHub Actions は timeout なし
   → ビルドログを詳しく確認
```

### Vercel デプロイ失敗

**症状**: Vercel で 404 が表示される

**原因と対応**:

```
1. build/web が GitHub Actions でコミットされていない
   → Actions タブで実行状況を確認
   → ビルドが成功したか確認

2. Vercel が古いコミットを使用している
   → Vercel ダッシュボードで "Redeploy" をクリック
   → 最新コミットを使用させる

3. outputDirectory の設定確認
   → vercel.json: "outputDirectory": "epl_match_simulator/build/web"
```

### API が動作しない

**症状**: 予測リクエストで 500 エラー

**原因と対応**:

```
1. CLAUDE_API_KEY が設定されていない
   → Vercel ダッシュボード → Environment Variables
   → CLAUDE_API_KEY を追加

2. API エンドポイントが見つからない
   → api/predictMatch.js が Vercel に deploy されているか確認
   → Vercel Functions タブで確認

3. CORS エラー
   → api/predictMatch.js で Access-Control-Allow-Origin が設定されているか確認
   → res.setHeader("Access-Control-Allow-Origin", "*");
```

## ベストプラクティス

### コミットメッセージ

GitHub Actions が自動生成したコミット以外は、以下の形式を推奨：

```bash
# ビルド資産の手動更新
git commit -m "Manual Flutter Web rebuild: fix [issue]"

# ソースコード変更（自動でビルド生成される）
git commit -m "Update: [feature/fix description]"
```

### ワークフロー修正

ワークフローファイルを編集した場合：

```bash
git add .github/workflows/flutter-web-build.yml
git commit -m "Update GitHub Actions workflow"
git push
# → 次のプッシュから新しいワークフローが実行される
```

### 手動ビルドトリガー

何か特別な理由で手動でビルドしたい場合：

```bash
# GitHub Web UI から
1. Actions タブ
2. "Flutter Web Build & Auto-commit" を選択
3. "Run workflow" をクリック
4. ブランチを選択 → "Run workflow"
```

## パフォーマンス比較

| 方式 | ビルド時間 | メリット | デメリット |
|------|-----------|--------|----------|
| **プリビルド資産** | 秒以下 | Vercel ビルド高速 | git リポジトリが大きくなる |
| **GitHub Actions** | 1-5分 | git リポジトリが小さい | GitHub Actions 実行が必要 |
| **Vercel ビルド** | 10-15分 | 最もシンプル | Vercel ビルド時間長い、失敗リスク高い |

## 参考資料

- [GitHub Actions: Flutter](https://github.com/subosito/flutter-action)
- [Vercel: Environment Variables](https://vercel.com/docs/environment-variables)
- [Flutter: Web Release](https://flutter.dev/docs/deployment/web)

## サマリー

このアプローチにより：

✅ プリビルド資産がなくても Vercel で動作
✅ ソースコード変更時に自動でビルド
✅ git リポジトリサイズが小さい（初回のみ資産を pull）
✅ スマホ Safari でも API が正常に動作
✅ CI/CD パイプラインが自動化される
