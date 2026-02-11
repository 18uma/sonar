# GitHubパイプライン + SonarCloud セットアップ手順

## 前提条件
- GitHubアカウント
- このプロジェクトをGitHubにpush済み

## ステップ1: SonarCloudアカウント作成（3分）

1. https://sonarcloud.io にアクセス
2. 「Log in」→「With GitHub」をクリック
3. GitHubで認証
4. 「Authorize SonarCloud」をクリック

## ステップ2: 組織の作成（2分）

1. 「Analyze new project」をクリック
2. 「Import an organization from GitHub」を選択
3. 自分のGitHubアカウントを選択
4. 「Install」をクリック（無料プランを選択）

## ステップ3: プロジェクトのインポート（2分）

1. SonarCloudのダッシュボードで「+」→「Analyze new project」
2. このリポジトリ（sonar）を選択
3. 「Set Up」をクリック
4. 「With GitHub Actions」を選択

## ステップ4: トークンの取得（1分）

画面に表示される手順:

1. トークンが自動生成される（例: `sqp_1234567890abcdef...`）
2. このトークンをコピー

## ステップ5: GitHubにシークレットを設定（2分）

1. GitHubリポジトリを開く
2. Settings → Secrets and variables → Actions
3. 「New repository secret」をクリック
4. Name: `SONAR_TOKEN`
5. Secret: コピーしたトークンを貼り付け
6. 「Add secret」をクリック

## ステップ6: ワークフローファイルの確認

すでに `.github/workflows/sonarcloud.yml` を作成済みです。
内容を確認してください。

## ステップ7: GitHubにpush

```bash
git add .
git commit -m "Add SonarCloud integration"
git push origin main
```

## ステップ8: 結果の確認

1. GitHubの「Actions」タブで実行状況を確認
2. 完了後、SonarCloudのダッシュボードで結果を確認
3. PRを作成すると、自動的にコメントが追加される

## 完了！

次回からは自動的に:
- mainブランチへのpush → フルスキャン
- Pull Request → 差分スキャン + コメント追加
