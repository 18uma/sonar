# SonarQubeの仕組み

## 1. 全体アーキテクチャ

```
┌─────────────────┐
│  開発者のPC     │
│  ┌───────────┐  │
│  │ ソースコード│  │
│  └─────┬─────┘  │
│        │        │
│        ▼        │
│  ┌───────────┐  │
│  │ Scanner   │  │ ← コードを解析
│  └─────┬─────┘  │
└────────┼────────┘
         │ 解析結果を送信
         ▼
┌─────────────────────────┐
│   SonarQubeサーバー      │
│  ┌──────────────────┐   │
│  │  Webサーバー      │   │ ← ダッシュボード表示
│  └──────────────────┘   │
│  ┌──────────────────┐   │
│  │  Compute Engine  │   │ ← 解析結果を処理
│  └──────────────────┘   │
│  ┌──────────────────┐   │
│  │  データベース     │   │ ← 結果を保存
│  │  (PostgreSQL)    │   │
│  └──────────────────┘   │
└─────────────────────────┘
         │
         ▼
    ブラウザで確認
```

## 2. 動作の流れ（詳細）

### ステップ1: スキャナーがコードを解析

```bash
sonar-scanner
```

**スキャナーが行うこと:**

1. **ソースコードの読み込み**
   - sonar-project.propertiesの設定を読む
   - 対象ファイルを特定（.py, .js, .java等）

2. **静的解析の実行**
   ```
   app.py を解析中...
   ├─ 構文解析（AST生成）
   ├─ ルールチェック
   │  ├─ セキュリティルール（S105: ハードコードされた認証情報）
   │  ├─ バグルール（S1481: 未使用変数）
   │  └─ コード品質ルール（S3776: 複雑度が高い）
   ├─ メトリクス計算
   │  ├─ 行数: 50行
   │  ├─ 複雑度: 15
   │  └─ 重複率: 20%
   └─ 結果をJSON形式で生成
   ```

3. **結果をサーバーに送信**
   ```json
   {
     "projectKey": "demo-project",
     "issues": [
       {
         "rule": "python:S105",
         "file": "app.py",
         "line": 5,
         "message": "ハードコードされた認証情報を削除してください",
         "severity": "CRITICAL"
       }
     ],
     "metrics": {
       "lines": 50,
       "complexity": 15
     }
   }
   ```

### ステップ2: サーバーが結果を処理

**Compute Engineの処理:**

1. **受信した解析結果を検証**
2. **データベースに保存**
   - 問題（Issues）
   - メトリクス（Metrics）
   - 履歴データ

3. **Quality Gateの評価**
   ```
   Quality Gate: "Sonar way"
   
   条件チェック:
   ✓ カバレッジ > 80%        → OK (85%)
   ✗ 新規バグ = 0            → NG (3件)
   ✗ 重大な脆弱性 = 0        → NG (2件)
   
   結果: FAILED
   ```

### ステップ3: ダッシュボードで確認

ブラウザで http://localhost:9000 にアクセスすると表示される

## 3. SonarQubeが検出する問題の種類

### A. バグ（Bugs）
実行時エラーを引き起こす可能性のあるコード

**例: app.pyの未使用変数**
```python
def unused_variable_example():
    x = 10
    y = 20
    z = 30  # ← 使われていない（バグの可能性）
    return x + y
```

**SonarQubeの検出:**
- ルール: S1481
- メッセージ: "変数 'z' は使用されていません"
- 理由: タイポの可能性、意図しない動作

### B. 脆弱性（Vulnerabilities）
セキュリティ上の問題

**例: app.pyのハードコードされた認証情報**
```python
API_KEY = "sk-1234567890abcdef"  # ← 危険！
PASSWORD = "admin123"
```

**SonarQubeの検出:**
- ルール: S105
- 重大度: CRITICAL
- 理由: コードが漏洩すると認証情報も漏洩

**例: SQLインジェクション**
```python
def sql_injection_vulnerable(user_input):
    query = "SELECT * FROM users WHERE name = '" + user_input + "'"
    # user_input = "'; DROP TABLE users; --" で攻撃可能
```

**SonarQubeの検出:**
- ルール: S3649
- 重大度: CRITICAL
- 推奨: パラメータ化クエリを使用

### C. コードスメル（Code Smells）
保守性を下げるコード

**例: 複雑度が高い関数**
```python
def complex_function(a, b, c, d, e, f):
    if a > 0:
        if b > 0:
            if c > 0:
                if d > 0:
                    if e > 0:
                        if f > 0:  # ← ネストが深すぎる
                            return a + b + c + d + e + f
```

**SonarQubeの検出:**
- ルール: S3776
- 複雑度: 15（推奨: 10以下）
- 理由: テストが困難、バグが混入しやすい

**例: 重複コード**
```python
def duplicate_code_1():
    result = 0
    for i in range(10):
        result += i * 2
    return result

def duplicate_code_2():
    result = 0
    for i in range(10):
        result += i * 2  # ← 同じコードが繰り返されている
    return result
```

**SonarQubeの検出:**
- ルール: S1192
- 理由: 修正時に複数箇所を変更する必要がある

## 4. ルールの仕組み

### ルールの構造

```yaml
ルールID: python:S105
名前: "ハードコードされた認証情報"
タイプ: 脆弱性
重大度: CRITICAL
説明: |
  パスワードやAPIキーをコードに直接書くと、
  ソースコードが漏洩した際に認証情報も漏洩します。
  
検出パターン:
  - 変数名に "password", "api_key", "secret" を含む
  - 値が文字列リテラル
  
修正方法:
  - 環境変数を使用
  - シークレット管理サービスを使用
```

### ルールの適用プロセス

```
1. スキャナーがコードを読む
   ↓
2. 抽象構文木（AST）に変換
   ↓
   API_KEY = "sk-1234567890abcdef"
   ↓
   AST: Assignment(
     target=Name(id='API_KEY'),
     value=Str(s='sk-1234567890abcdef')
   )
   ↓
3. 各ルールを適用
   ↓
   S105ルール: 
   - 変数名に "KEY" を含む? → YES
   - 値が文字列リテラル? → YES
   - 問題として報告！
```

## 5. メトリクスの計算

### 複雑度（Cyclomatic Complexity）

**計算方法:**
```python
def example(x, y):  # 開始: 1
    if x > 0:       # +1 = 2
        if y > 0:   # +1 = 3
            return x + y
        else:       # +1 = 4
            return x
    return 0

# 複雑度 = 4
```

**意味:**
- テストケースの最小数
- 複雑度4 = 最低4つのテストが必要

### 重複率

```python
# ファイル1
def func1():
    x = 1
    y = 2
    return x + y

# ファイル2
def func2():
    x = 1  # ← 同じコード
    y = 2  # ← 同じコード
    return x + y  # ← 同じコード

# 重複率 = (重複行数 / 総行数) × 100
```

### 技術的負債（Technical Debt）

```
問題の修正時間を見積もり:
- Critical脆弱性: 30分
- Major複雑度: 20分
- Minor未使用変数: 5分

合計: 55分 = 技術的負債
```

## 6. Quality Gateの仕組み

### Quality Gateとは
コードの品質基準。条件を満たさないとビルドを失敗させる。

### デフォルト設定（Sonar way）

```yaml
新規コードの条件:
  - カバレッジ >= 80%
  - 重複率 <= 3%
  - 新規バグ = 0
  - 新規脆弱性 = 0
  - 新規セキュリティホットスポット = 0
  - 保守性評価 >= A

全体コードの条件:
  - セキュリティ評価 >= A
  - 信頼性評価 >= A
```

### 評価プロセス

```
スキャン完了
  ↓
Compute Engineが評価
  ↓
┌─────────────────────┐
│ 新規バグ: 3件       │ ← 条件: 0件
│ 結果: FAILED        │
└─────────────────────┘
  ↓
CI/CDパイプラインに結果を返す
  ↓
exit 1（ビルド失敗）
```

## 7. 新規コード vs 全体コード

### 新規コードの定義

```
main ブランチ
  │
  ├─ commit A (1週間前)
  │
  ├─ commit B (3日前)
  │
  └─ commit C (今日) ← この差分が「新規コード」
```

**設定:**
```properties
sonar.newCode.referenceBranch=main
```

**メリット:**
- 既存の問題を無視できる
- 新しいコードのみ品質を保証
- 段階的な改善が可能

## 8. データの保存と履歴

### データベース構造（概念）

```sql
-- プロジェクト
projects
  id, key, name

-- 問題
issues
  id, project_id, rule_key, file, line, message, status
  
-- メトリクス履歴
metrics_history
  project_id, date, metric_name, value

-- スナップショット
snapshots
  project_id, created_at, version
```

### 履歴の活用

```
グラフ表示:
  
バグ数の推移
  │
10│     ●
  │    ╱
 5│   ●
  │  ╱
 0│●─────────────
  └─────────────
  1月 2月 3月
  
→ 改善傾向が可視化される
```

## 9. 実際の解析例（app.py）

### スキャン実行時のログ

```
INFO: Scanner configuration file: sonar-project.properties
INFO: Project root configuration file: NONE
INFO: Analyzing on SonarQube server 9.9
INFO: Base dir: /usr/src
INFO: Working dir: /usr/src/.scannerwork
INFO: Source paths: .
INFO: Source encoding: UTF-8
INFO: Load global settings
INFO: Load project settings
INFO: Load quality profiles
INFO: Load active rules
INFO: Indexing files...
INFO: 1 file indexed
INFO: Quality profile for py: Sonar way
INFO: Sensor Python Sensor [python]
INFO: Starting global symbols computation
INFO: 1 source file to be analyzed
INFO: Analyzing app.py
INFO: 1/1 source file has been analyzed
INFO: Sensor Python Sensor [python] (done) | time=234ms
INFO: Sensor SonarQube Scanner Sensor [scanner]
INFO: Sensor SonarQube Scanner Sensor [scanner] (done) | time=12ms
INFO: Analysis report generated in 89ms
INFO: Analysis report uploaded in 156ms
INFO: ANALYSIS SUCCESSFUL
```

### 検出される問題

```
app.py:
  Line 5:  [CRITICAL] ハードコードされた認証情報 (S105)
  Line 6:  [CRITICAL] ハードコードされた認証情報 (S105)
  Line 9:  [CRITICAL] 安全でないデシリアライゼーション (S5135)
  Line 13: [CRITICAL] SQLインジェクション (S3649)
  Line 18: [MINOR] 未使用変数 'z' (S1481)
  Line 21: [MAJOR] 複雑度が高すぎる (S3776)
  Line 36: [MAJOR] 重複コード (S1192)
  Line 44: [INFO] デッドコード (S1172)

合計: 8件の問題
  - Critical: 4件
  - Major: 2件
  - Minor: 1件
  - Info: 1件
```

## 10. まとめ: SonarQubeの価値

### 自動化できること
✓ セキュリティ脆弱性の検出
✓ バグの早期発見
✓ コード品質の可視化
✓ 技術的負債の定量化

### 自動化できないこと
✗ ビジネスロジックの正しさ
✗ 設計の妥当性
✗ パフォーマンスの最適化（一部のみ）
✗ ユーザー体験

### 効果的な使い方
1. **予防**: コミット前にローカルでスキャン
2. **検証**: PR時に自動スキャン
3. **改善**: 定期的に技術的負債を返済
4. **学習**: 検出された問題から学ぶ
