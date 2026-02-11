# app.py の解析結果サンプル

## ダッシュボード概要

```
┌─────────────────────────────────────────────────────────┐
│ demo-project                                            │
│                                                         │
│ Quality Gate: ❌ Failed                                 │
│                                                         │
│ ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐   │
│ │  バグ   │  │ 脆弱性  │  │コードス │  │セキュリ │   │
│ │   1     │  │   3     │  │ メル    │  │ティホッ │   │
│ │         │  │         │  │   4     │  │トスポッ │   │
│ │         │  │         │  │         │  │  ト 0   │   │
│ └─────────┘  └─────────┘  └─────────┘  └─────────┘   │
│                                                         │
│ ┌─────────────────────────────────────────────────┐   │
│ │ 技術的負債: 2時間15分                            │   │
│ │ 重複率: 20%                                      │   │
│ │ カバレッジ: 0%                                   │   │
│ │ 行数: 50                                         │   │
│ │ 複雑度: 15                                       │   │
│ └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## 検出された問題の詳細

### 🔴 Critical（重大）

#### 1. ハードコードされた認証情報
```
ファイル: app.py
行: 5
ルール: python:S105

API_KEY = "sk-1234567890abcdef"  # ← ここ
         ^^^^^^^^^^^^^^^^^^^^^^^

問題:
認証情報がソースコードに直接書かれています。
コードが漏洩すると認証情報も漏洩します。

修正方法:
import os
API_KEY = os.environ.get('API_KEY')

技術的負債: 30分
```

#### 2. ハードコードされたパスワード
```
ファイル: app.py
行: 6
ルール: python:S105

PASSWORD = "admin123"  # ← ここ
          ^^^^^^^^^^^

問題:
パスワードがソースコードに直接書かれています。

修正方法:
import os
PASSWORD = os.environ.get('PASSWORD')

技術的負債: 30分
```

#### 3. 安全でないデシリアライゼーション
```
ファイル: app.py
行: 9
ルール: python:S5135

def unsafe_deserialize(data):
    return pickle.loads(data)  # ← ここ
           ^^^^^^^^^^^^^^^^^^^

問題:
pickleは任意のコード実行を許してしまいます。
攻撃者が細工したデータを送ると、サーバーで
任意のコードが実行される可能性があります。

修正方法:
import json
def safe_deserialize(data):
    return json.loads(data)  # JSONを使用

技術的負債: 45分
```

#### 4. SQLインジェクション
```
ファイル: app.py
行: 13
ルール: python:S3649

def sql_injection_vulnerable(user_input):
    query = "SELECT * FROM users WHERE name = '" + user_input + "'"
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

問題:
ユーザー入力を直接SQL文に連結しています。
攻撃例: user_input = "'; DROP TABLE users; --"

修正方法:
def safe_query(user_input):
    query = "SELECT * FROM users WHERE name = ?"
    cursor.execute(query, (user_input,))

技術的負債: 30分
```

### 🟠 Major（重要）

#### 5. 複雑度が高すぎる
```
ファイル: app.py
行: 21
ルール: python:S3776
複雑度: 15（推奨: 10以下）

def complex_function(a, b, c, d, e, f):
    if a > 0:
        if b > 0:
            if c > 0:
                if d > 0:
                    if e > 0:
                        if f > 0:  # ← ネストが深すぎる
                            return a + b + c + d + e + f

問題:
- テストが困難
- 理解が困難
- バグが混入しやすい

修正方法:
def simple_function(a, b, c, d, e, f):
    values = [a, b, c, d, e, f]
    if all(v > 0 for v in values):
        return sum(values)
    # 早期リターンで複雑度を下げる
    return sum(v for v in values if v > 0)

技術的負債: 20分
```

#### 6. 重複コード
```
ファイル: app.py
行: 36-40, 42-46
ルール: python:S1192

def duplicate_code_1():
    result = 0
    for i in range(10):
        result += i * 2  # ← この3行が
    return result

def duplicate_code_2():
    result = 0
    for i in range(10):
        result += i * 2  # ← 重複している
    return result

問題:
同じコードが複数箇所にあると、修正時に
すべての箇所を変更する必要があります。

修正方法:
def calculate_sum():
    result = 0
    for i in range(10):
        result += i * 2
    return result

def duplicate_code_1():
    return calculate_sum()

def duplicate_code_2():
    return calculate_sum()

技術的負債: 10分
```

### 🟡 Minor（軽微）

#### 7. 未使用変数
```
ファイル: app.py
行: 18
ルール: python:S1481

def unused_variable_example():
    x = 10
    y = 20
    z = 30  # ← 使われていない
    return x + y

問題:
変数zが定義されているが使用されていません。
- タイポの可能性
- 意図しない動作の可能性

修正方法:
def unused_variable_example():
    x = 10
    y = 20
    return x + y

技術的負債: 5分
```

### ℹ️ Info（情報）

#### 8. デッドコード
```
ファイル: app.py
行: 49
ルール: python:S1172

def never_called_function():  # ← どこからも呼ばれていない
    print("This is never called")
    return None

問題:
この関数はどこからも呼ばれていません。
不要なコードは削除すべきです。

修正方法:
# 関数を削除

技術的負債: 5分
```

## Quality Gate評価

```
┌─────────────────────────────────────────────┐
│ Quality Gate: Sonar way                     │
├─────────────────────────────────────────────┤
│                                             │
│ 新規コードの条件:                            │
│ ✓ カバレッジ >= 80%        (N/A)            │
│ ✓ 重複率 <= 3%             (20%) ❌         │
│ ✗ 新規バグ = 0             (1件) ❌         │
│ ✗ 新規脆弱性 = 0           (3件) ❌         │
│                                             │
│ 全体コードの条件:                            │
│ ✗ セキュリティ評価 >= A    (E) ❌           │
│ ✗ 信頼性評価 >= A          (C) ❌           │
│ ✗ 保守性評価 >= A          (C) ❌           │
│                                             │
│ 結果: ❌ FAILED                             │
└─────────────────────────────────────────────┘
```

## 評価の内訳

### セキュリティ評価: E（最低）
```
脆弱性: 3件
  - Critical: 3件
  - Major: 0件
  - Minor: 0件

評価基準:
  A: 0件
  B: 1件（Minor）
  C: 1件（Major）
  D: 1件（Critical）
  E: 2件以上（Critical）← 現在ここ
```

### 信頼性評価: C
```
バグ: 1件
  - Critical: 0件
  - Major: 0件
  - Minor: 1件

評価基準:
  A: 0件
  B: 1件（Minor）← 現在ここ
  C: 1件（Major）
  D: 1件（Critical）
  E: 2件以上（Critical）
```

### 保守性評価: C
```
コードスメル: 4件
技術的負債比率: 8.9%

評価基準:
  A: <= 5%
  B: 6-10%
  C: 11-20% ← 現在ここ
  D: 21-50%
  E: > 50%
```

## 優先順位付け

### 今すぐ修正すべき（Critical）
1. ✅ ハードコードされた認証情報（2箇所）→ 環境変数化
2. ✅ SQLインジェクション → パラメータ化クエリ
3. ✅ 安全でないデシリアライゼーション → JSON使用

### 次に修正すべき（Major）
4. 🔶 複雑度が高い関数 → リファクタリング
5. 🔶 重複コード → 共通化

### 余裕があれば修正（Minor/Info）
6. 🔹 未使用変数 → 削除
7. 🔹 デッドコード → 削除

## 修正後の予想

```
修正前:
  バグ: 1件
  脆弱性: 3件
  コードスメル: 4件
  技術的負債: 2時間15分
  Quality Gate: ❌ FAILED

修正後:
  バグ: 0件
  脆弱性: 0件
  コードスメル: 0件
  技術的負債: 0分
  Quality Gate: ✅ PASSED
```

## CI/CDでの影響

### 現在の状態
```bash
$ sonar-scanner
...
INFO: ANALYSIS SUCCESSFUL
INFO: Quality Gate status: FAILED

$ echo $?
1  # ← ビルドが失敗する
```

### パイプラインへの影響
```yaml
# GitHub Actions
- name: SonarQube Quality Gate check
  run: |
    # Quality Gateが失敗すると...
    exit 1  # ← ここで止まる

- name: Deploy  # ← ここには到達しない
  run: deploy.sh
```

**結果:**
- ✅ 品質の低いコードはデプロイされない
- ❌ 開発者はすぐに修正する必要がある
- ⚠️ 既存コードが多いと導入が困難
