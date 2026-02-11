# SonarQube ハンズオン

## セットアップ手順

### 1. SonarQubeの起動

```bash
docker-compose up -d
```

起動後、ブラウザで http://localhost:9000 にアクセス
- 初期ユーザー名: `admin`
- 初期パスワード: `admin`
- 初回ログイン時にパスワード変更を求められます

### 2. トークンの生成

1. ログイン後、右上のユーザーアイコン → My Account
2. Security タブ → Generate Tokens
3. トークン名を入力（例: `demo-token`）
4. Generate をクリック
5. **生成されたトークンをコピーして保存**（後で使用）

### 3. スキャンの実行

#### 方法1: Docker経由（推奨）

```bash
docker run --rm \
  --network=host \
  -v "$(pwd):/usr/src" \
  sonarsource/sonar-scanner-cli \
  -Dsonar.projectKey=demo-project \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=YOUR_TOKEN_HERE
```

#### 方法2: ローカルインストール

```bash
# macOSの場合
brew install sonar-scanner

# スキャン実行
sonar-scanner \
  -Dsonar.projectKey=demo-project \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=YOUR_TOKEN_HERE
```

### 4. 結果の確認

http://localhost:9000/dashboard?id=demo-project にアクセス

## パイプライン統合の課題

### 課題1: 環境構築の複雑さ
- SonarQubeサーバーの運用（メモリ、ストレージ）
- データベースの管理（本番環境では外部DB推奨）
- バージョン管理とアップグレード

### 課題2: CI/CDパイプラインへの組み込み
- トークン管理（シークレット管理）
- スキャン時間の増加（大規模プロジェクトで数分〜数十分）
- Quality Gateの設定と運用ルール

### 課題3: チーム運用
- 誤検知（False Positive）の対応
- 既存コードの大量の問題への対処
- 開発者の学習コスト

## CI/CDパイプライン例

### GitHub Actions

```yaml
name: SonarQube Scan
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  sonarqube:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: SonarQube Scan
        uses: sonarsource/sonarqube-scan-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
```

### GitLab CI

```yaml
sonarqube-check:
  image: sonarsource/sonar-scanner-cli:latest
  variables:
    SONAR_USER_HOME: "${CI_PROJECT_DIR}/.sonar"
    GIT_DEPTH: "0"
  cache:
    key: "${CI_JOB_NAME}"
    paths:
      - .sonar/cache
  script:
    - sonar-scanner
  only:
    - merge_requests
    - main
```

## 停止とクリーンアップ

```bash
# 停止
docker-compose down

# データも削除する場合
docker-compose down -v
```
# Test commit to trigger GitHub Actions
