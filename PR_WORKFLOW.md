# Pull Requestでの動作

## PRを作成すると何が起こるか

### 1. 自動スキャンが実行される

```
Pull Request作成
  ↓
GitHub Actions起動
  ↓
SonarCloudスキャン実行
  ↓
結果をPRにコメント
```

### 2. PRに表示される情報

#### コメント例:
```
🔍 SonarCloud Quality Gate: Failed

Issues:
  🔴 3 Bugs
  🔴 4 Vulnerabilities
  🟡 2 Code Smells

Coverage: 0.0% (-0.0%)
Duplications: 20.0% (+20.0%)

View details on SonarCloud →
```

#### チェック結果:
```
✅ SonarCloud Code Analysis
   ↳ Quality Gate passed
   
または

❌ SonarCloud Code Analysis
   ↳ Quality Gate failed
```

### 3. Quality Gateが失敗した場合

**オプションA: マージをブロック（推奨）**
```
Settings → Branches → Branch protection rules
☑ Require status checks to pass before merging
  ☑ SonarCloud Code Analysis
```

**結果:**
- Quality Gate失敗 → マージ不可
- 開発者は修正してから再push

**オプションB: 警告のみ**
```
Quality Gateが失敗してもマージ可能
（段階的導入時に使用）
```

### 4. 実際のPRフロー

```bash
# 1. 新しいブランチを作成
git checkout -b fix/security-issues

# 2. コードを修正
# app.pyのハードコードされた認証情報を修正
cat > app.py << 'EOF'
import os

# 修正: 環境変数から取得
API_KEY = os.environ.get('API_KEY')
PASSWORD = os.environ.get('PASSWORD')
EOF

# 3. コミット & プッシュ
git add app.py
git commit -m "Fix: Remove hardcoded credentials"
git push origin fix/security-issues

# 4. GitHubでPRを作成
# → 自動的にSonarCloudスキャンが実行される

# 5. 結果を確認
# → PRのコメントとチェック結果を確認

# 6. Quality Gate通過後にマージ
```

### 5. 差分スキャンの動作

**mainブランチ:**
```python
# 既存の問題（8件）
API_KEY = "sk-123"  # ← 既存の問題
PASSWORD = "admin"  # ← 既存の問題
# ... 他6件
```

**PRブランチ:**
```python
# 新しい問題を追加
SECRET_KEY = "secret123"  # ← 新しい問題！
```

**SonarCloudの評価:**
```
既存の問題: 8件 → 無視（既存コード）
新しい問題: 1件 → 検出！

結果: Quality Gate Failed
理由: 新規脆弱性 1件（許容: 0件）
```

### 6. レビュアーの視点

PRを見ると:
```
Files changed タブ:
  app.py の変更内容

Checks タブ:
  ❌ SonarCloud Code Analysis
     3 new issues found
     - 1 Critical vulnerability
     - 2 Code smells
     
  詳細を見る → SonarCloudへ
```

**レビュアーの判断:**
- Critical/Major → 修正必須
- Minor → 議論の余地あり
- 誤検知 → SonarCloudで「Won't Fix」マーク

### 7. 段階的な導入

#### フェーズ1: レポートのみ（1-2週間）
```yaml
# .github/workflows/sonarcloud.yml
jobs:
  sonarcloud:
    continue-on-error: true  # ← 失敗してもOK
```

**効果:**
- チームが慣れる
- 誤検知を特定
- ルールを調整

#### フェーズ2: 警告モード（1ヶ月）
```
Branch protection: OFF
SonarCloud: ON（コメントのみ）
```

**効果:**
- 問題を可視化
- 修正の優先順位を決定
- 既存問題の対応計画

#### フェーズ3: 強制モード（継続）
```
Branch protection: ON
  ☑ Require SonarCloud check
```

**効果:**
- 新しい問題の混入を防止
- コード品質の維持

### 8. 実際の業務での使い方

#### 開発者の日常:
```
1. 機能開発
   ↓
2. ローカルでテスト
   ↓
3. PRを作成
   ↓
4. SonarCloudの結果を確認
   ↓
5. 問題があれば修正
   ↓
6. 再push（自動で再スキャン）
   ↓
7. Quality Gate通過
   ↓
8. レビュー依頼
   ↓
9. マージ
```

#### レビュアーの視点:
```
1. PRを開く
   ↓
2. SonarCloudのコメントを確認
   ↓
3. 重大な問題がないか確認
   ↓
4. コードレビュー
   ↓
5. 承認 or 修正依頼
```

### 9. トラブルシューティング

#### Q: スキャンが失敗する
```
Checks タブで詳細を確認:
- トークンの有効期限切れ？
- sonar-project.propertiesの設定ミス？
- ファイルサイズが大きすぎる？
```

#### Q: 誤検知が多い
```
SonarCloudで個別に対応:
1. 問題を開く
2. "Won't Fix" または "False Positive" をマーク
3. 理由をコメント
```

#### Q: 既存コードの問題が多すぎる
```
sonar-project.properties で新規コードのみ対象:
sonar.newCode.referenceBranch=main
```

### 10. 次のステップ

実際に試してみましょう:

```bash
# 1. GitHubリポジトリを作成
./setup-github.sh

# 2. SonarCloudをセットアップ
# SONARCLOUD_SETUP.md を参照

# 3. PRを作成して動作確認
git checkout -b test/sonarcloud
echo "# Test" >> README.md
git add README.md
git commit -m "Test SonarCloud integration"
git push origin test/sonarcloud
# GitHubでPRを作成

# 4. 結果を確認
# PRのコメントとチェック結果を確認
```
