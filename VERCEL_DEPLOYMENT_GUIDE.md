# Vercel Flutter Web デプロイメント ガイド

## 問題の解決

以前のビルドスクリプトは、Vercel のビルド環境で Flutter SDK（1.5GB）をダウンロード・抽出しようとしていました。これにより以下の問題が発生していました：

```
xz: (stdin): File format not recognized
tar: Child returned status 1
tar: Error is not recoverable: exiting now
ERROR: Failed to extract Flutter SDK
```

### 根本原因の分析

1. **ファイルサイズの問題**: 1.5GB の Flutter SDK ダウンロードは Vercel のビルド時間制限内に完了できない可能性
2. **ネットワークの不安定性**: Vercel 環境で大規模ファイルダウンロード中の接続問題
3. **リソース制限**: Vercel のビルド環境でのメモリ・ディスク制限

## 実装された解決策

### 方法：プリビルド済みアセットの使用（推奨）

**最も堅牢で実用的なソリューション**

```bash
# vercel-build.sh の主要なフロー

1. epl_match_simulator/build/web の存在を確認
2. 存在すれば、そのまま使用（ビルド完了）
3. 存在しない場合のみ、Flutter SDK ダウンロード・ビルド
```

**メリット:**

- **高速**: ビルド時間が数秒に短縮
- **確実**: 環境依存性を最小化
- **シンプル**: 静的アセット配信で十分
- **保守性**: git で version 管理可能

### .gitignore の更新

```gitignore
# 変更前（build/ 全体が無視）
epl_match_simulator/build/

# 変更後（Web アセットのみ含む）
epl_match_simulator/build/ios/
epl_match_simulator/build/macos/
epl_match_simulator/build/android/
epl_match_simulator/build/windows/
epl_match_simulator/build/linux/
# epl_match_simulator/build/web は含まれない（git に追加される）
```

### vercel-build.sh の改善点

1. **プリビルド確認**: 最初に `build/web` の存在確認
2. **ファイルタイプ検証**: ダウンロード後に `file` コマンドで XZ 形式を確認
3. **タイムアウト設定**: `--max-time 600 --connect-timeout 30`
4. **エラーハンドリング**: より詳細なエラーメッセージ

## 他の選択肢（参考）

### オプション 1：GitHub Release から直接ダウンロード

**利点:** Google Storage より高速な場合がある
**欠点:** 多少複雑

```bash
# 例：Releases の tar.gz から直接ダウンロード
curl -L https://github.com/flutter/flutter/releases/download/3.41.9-stable/flutter-linux-x64-3.41.9-stable.tar.xz
```

### オプション 2：キャッシング戦略

**利点:** 2回目以降のビルドが高速
**欠点:** Vercel の無料プランではキャッシング機能に制限がある可能性

```json
{
  "buildCache": {
    "_flutter": "packages"
  }
}
```

### オプション 3：Docker ベースのカスタムビルド

**利点:** 完全な制御が可能
**欠点:** 複雑性が高い

```dockerfile
FROM ghcr.io/flutter/flutter:latest
COPY epl_match_simulator /app
RUN cd /app && flutter build web --release
```

## テストと検証

### ローカルでの検証

```bash
# vercel-build.sh が正しく機能するか確認
bash vercel-build.sh

# build/web が正しく生成されているか確認
ls -la epl_match_simulator/build/web/
file epl_match_simulator/build/web/index.html
```

### Vercel でのデプロイ

```bash
# git にコミット
git commit -am "Update build assets"
git push origin <branch>

# Vercel が自動的に デプロイ
```

## 今後の開発フロー

### アプリを更新する場合

```bash
# 1. Flutter アプリをローカルで更新
cd epl_match_simulator
flutter build web --release

# 2. 更新されたアセットを git にコミット
git add -f build/web/
git commit -m "Update Flutter web build"
git push
```

### Flutter バージョン更新時

```bash
# 1. Flutter バージョンを更新
flutter upgrade

# 2. ビルドを再生成
flutter build web --release

# 3. git にコミット
git add -f build/web/
git commit -m "Rebuild with updated Flutter version"
git push
```

## トラブルシューティング

### Vercel ビルドが失敗する場合

1. **build/web が最新か確認**
   ```bash
   git log --oneline epl_match_simulator/build/web/ | head -5
   ```

2. **ローカルで build を再生成**
   ```bash
   flutter build web --release
   git add -f epl_match_simulator/build/web/
   git commit -m "Rebuild web assets"
   git push
   ```

3. **vercel.json の outputDirectory を確認**
   ```json
   {
     "outputDirectory": "epl_match_simulator/build/web"
   }
   ```

### ファイルサイズが大きい場合

`.git/objects` が大きくなる可能性があります。以下で確認：

```bash
du -sh .git/
git count-objects -v
```

## 参考資料

- Flutter Web 公式ドキュメント: https://flutter.dev/docs/get-started/web
- Vercel デプロイメント: https://vercel.com/docs/deployments/overview
- Flutter リリース: https://flutter.dev/docs/release/release-notes

## まとめ

このアプローチにより、Vercel への Flutter Web デプロイメントが：

- **高速化**: 数秒でデプロイ完了
- **信頼性向上**: 環境依存性を排除
- **保守性向上**: プリビルド済みアセットで version 管理可能

大規模な Flutter SDK ダウンロードの問題は完全に解決されました。
