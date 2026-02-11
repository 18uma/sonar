# SonarQubeサーバーの配置オプション

## 選択肢の比較

### ❌ オプション1: ローカル（開発者のPC）
```
docker-compose up -d  # ← 今回のハンズオン用
```

**メリット:**
- セットアップが簡単
- ハンズオンや検証に最適

**デメリット:**
- ✗ メモリ消費: 4-8GB
- ✗ 常時起動が必要
- ✗ チームで共有できない
- ✗ 履歴が個人PCに依存

**結論: 本番運用には不向き**

---

### ✅ オプション2: SonarCloud（SaaS版）← 推奨

```
https://sonarcloud.io
```

**メリット:**
- ✓ サーバー運用不要
- ✓ 自動アップデート
- ✓ 無制限のストレージ
- ✓ すぐに使える

**料金:**
- パブリックリポジトリ: 無料
- プライベートリポジトリ: 
  - 10万行まで: 無料
  - 100万行: €10/月（約1,500円）
  - 200万行: €75/月（約11,000円）

**設定例:**
```yaml
# .github/workflows/sonarcloud.yml
name: SonarCloud
on:
  push:
    branches: [main]
  pull_request:

jobs:
  sonarcloud:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      
      - name: SonarCloud Scan
        uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

**結論: 中小規模チームに最適**

---

### ✅ オプション3: クラウドホスティング（AWS/GCP/Azure）

#### 3-1. EC2/Compute Engine/VM
```
┌─────────────────────────┐
│ AWS EC2                 │
│ - t3.large (2vCPU, 8GB) │
│ - 50GB EBS              │
│ - RDS PostgreSQL        │
└─────────────────────────┘
```

**料金（AWS東京リージョン）:**
- EC2 t3.large: $0.1088/時間 × 730時間 = 約$80/月
- RDS db.t3.small: 約$30/月
- EBS 50GB: 約$5/月
- **合計: 約$115/月（約17,000円）**

**メリット:**
- ✓ 完全なコントロール
- ✓ カスタマイズ可能
- ✓ データの完全な所有権

**デメリット:**
- ✗ 運用が必要（アップデート、バックアップ）
- ✗ セキュリティ管理
- ✗ 初期セットアップが複雑

#### 3-2. ECS/Cloud Run（コンテナ）
```yaml
# docker-compose.yml をそのまま使える
services:
  sonarqube:
    image: sonarqube:community
    environment:
      - SONAR_JDBC_URL=jdbc:postgresql://rds-endpoint/sonar
```

**料金（AWS Fargate）:**
- 0.5vCPU, 2GB: 約$30/月
- RDS: 約$30/月
- **合計: 約$60/月（約9,000円）**

#### 3-3. Kubernetes（大規模向け）
```yaml
# helm install
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm install sonarqube sonarqube/sonarqube
```

**料金:**
- EKS/GKE: 約$70/月（クラスター）
- ノード: 約$50/月
- **合計: 約$120/月（約18,000円）**

---

### ✅ オプション4: CI/CD統合サービス

#### GitHub Advanced Security
```
GitHub Enterprise Cloud に含まれる
```

**料金:**
- $21/ユーザー/月

**メリット:**
- ✓ GitHubに統合
- ✓ CodeQL（セキュリティスキャン）
- ✓ Dependabot（依存関係）
- ✓ Secret scanning

**デメリット:**
- ✗ SonarQubeほど詳細ではない
- ✗ コード品質メトリクスが限定的

#### GitLab Ultimate
```
GitLab Ultimate に含まれる
```

**料金:**
- $99/ユーザー/月

**メリット:**
- ✓ GitLabに統合
- ✓ SAST, DAST, 依存関係スキャン
- ✓ コードカバレッジ

---

## 実際の企業での選択例

### スタートアップ（5-20名）
```
選択: SonarCloud
理由: 
  - 運用コスト0
  - すぐに使える
  - スケールしやすい
コスト: €10-75/月
```

### 中規模企業（50-200名）
```
選択: AWS ECS + RDS
理由:
  - データの完全な管理
  - カスタマイズ可能
  - 既存のAWSインフラと統合
コスト: $60-150/月
```

### 大企業（500名以上）
```
選択: Kubernetes on AWS/GCP
理由:
  - 高可用性
  - 複数プロジェクト
  - エンタープライズ機能
コスト: $500-2000/月
```

---

## 推奨フロー

### ステップ1: 検証（1-2週間）
```bash
# ローカルで試す
docker-compose up -d
```
- 機能を理解
- チームの反応を確認

### ステップ2: パイロット（1-2ヶ月）
```
SonarCloud 無料プラン
```
- 1-2プロジェクトで試験運用
- CI/CD統合を確認
- ROIを測定

### ステップ3: 本番導入
```
選択肢A: SonarCloud（運用不要）
選択肢B: AWS ECS（コントロール重視）
```

---

## コスト比較表

| オプション | 初期費用 | 月額費用 | 運用工数 | 推奨規模 |
|-----------|---------|---------|---------|---------|
| ローカル | 0円 | 0円 | 低 | 検証のみ |
| **SonarCloud** | **0円** | **0-11,000円** | **なし** | **5-100名** |
| AWS EC2 | 5万円 | 17,000円 | 中 | 50-200名 |
| AWS ECS | 2万円 | 9,000円 | 低 | 20-100名 |
| Kubernetes | 10万円 | 18,000円 | 高 | 200名以上 |

---

## 実際の設定例: SonarCloud

### 1. アカウント作成（5分）
```
1. https://sonarcloud.io にアクセス
2. GitHubでログイン
3. 組織を作成
```

### 2. プロジェクト連携（3分）
```
1. "Analyze new project" をクリック
2. GitHubリポジトリを選択
3. トークンをコピー
```

### 3. GitHub Actionsに追加（2分）
```yaml
# .github/workflows/sonarcloud.yml
name: SonarCloud
on:
  push:
    branches: [main]
  pull_request:

jobs:
  sonarcloud:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      
      - uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

### 4. 完了
```
次回のpushから自動スキャン開始
サーバー運用: 不要
```

---

## 実際の設定例: AWS ECS（運用したい場合）

### Terraform設定
```hcl
# main.tf
resource "aws_ecs_cluster" "sonarqube" {
  name = "sonarqube-cluster"
}

resource "aws_ecs_task_definition" "sonarqube" {
  family                   = "sonarqube"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "4096"

  container_definitions = jsonencode([{
    name  = "sonarqube"
    image = "sonarqube:community"
    portMappings = [{
      containerPort = 9000
      protocol      = "tcp"
    }]
    environment = [
      {
        name  = "SONAR_JDBC_URL"
        value = "jdbc:postgresql://${aws_db_instance.sonarqube.endpoint}/sonar"
      }
    ]
  }])
}

resource "aws_db_instance" "sonarqube" {
  identifier        = "sonarqube-db"
  engine            = "postgres"
  instance_class    = "db.t3.small"
  allocated_storage = 20
  db_name           = "sonar"
  username          = "sonar"
  password          = var.db_password
}
```

**デプロイ:**
```bash
terraform init
terraform apply
# 約10分で完成
```

---

## 結論: あなたのチームには？

### SonarCloudを選ぶべき場合（90%のケース）
- ✓ サーバー運用したくない ← あなたのケース
- ✓ チーム規模: 5-100名
- ✓ すぐに始めたい
- ✓ コストを抑えたい

### セルフホストを選ぶべき場合
- ✓ データを外部に出せない（金融、医療等）
- ✓ 完全なカスタマイズが必要
- ✓ 既存のインフラと統合したい
- ✓ 運用チームがいる

---

## 次のステップ

### 今日のハンズオン
```bash
# ローカルで機能を理解
docker-compose up -d
./run-scan.sh
```

### 明日以降
```
1. SonarCloudアカウント作成（無料）
2. 実際のプロジェクトで試す
3. チームで評価
4. 本番導入を判断
```

**推奨: まずSonarCloudで始める**
- 無料で試せる
- 運用不要
- 後でセルフホストに移行も可能
