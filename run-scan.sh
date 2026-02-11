#!/bin/bash

echo "==================================="
echo "SonarQube ハンズオン実行スクリプト"
echo "==================================="
echo ""

# ステップ1: SonarQubeの起動確認
echo "ステップ1: SonarQubeの起動状態を確認"
if docker ps | grep -q sonarqube; then
    echo "✓ SonarQubeは既に起動しています"
else
    echo "✗ SonarQubeが起動していません"
    echo ""
    echo "以下のコマンドで起動してください:"
    echo "  docker-compose up -d"
    echo ""
    echo "起動後、http://localhost:9000 にアクセスしてください"
    echo "初期ログイン: admin / admin"
    exit 1
fi

echo ""
echo "ステップ2: トークンの確認"
echo "SonarQubeのトークンを環境変数に設定してください:"
echo "  export SONAR_TOKEN=your_token_here"
echo ""

if [ -z "$SONAR_TOKEN" ]; then
    echo "✗ SONAR_TOKEN が設定されていません"
    echo ""
    echo "トークンの生成方法:"
    echo "1. http://localhost:9000 にログイン"
    echo "2. 右上のユーザーアイコン → My Account"
    echo "3. Security タブ → Generate Tokens"
    echo "4. トークン名を入力して Generate"
    echo "5. 生成されたトークンをコピー"
    echo ""
    read -p "トークンを入力してください: " SONAR_TOKEN
    export SONAR_TOKEN
fi

echo "✓ トークンが設定されました"
echo ""

# ステップ3: スキャンの実行
echo "ステップ3: SonarQubeスキャンを実行"
echo "実行中..."
echo ""

docker run --rm \
  --network=host \
  -e SONAR_HOST_URL=http://localhost:9000 \
  -e SONAR_TOKEN="$SONAR_TOKEN" \
  -v "$(pwd):/usr/src" \
  sonarsource/sonar-scanner-cli

echo ""
echo "==================================="
echo "スキャン完了！"
echo "==================================="
echo ""
echo "結果を確認:"
echo "http://localhost:9000/dashboard?id=demo-project"
echo ""
