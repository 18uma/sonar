#!/bin/bash

echo "=========================================="
echo "GitHubリポジトリ作成とSonarCloud連携"
echo "=========================================="
echo ""

# ステップ1: Gitリポジトリの初期化
echo "ステップ1: Gitリポジトリの初期化"
if [ -d .git ]; then
    echo "✓ 既にGitリポジトリです"
else
    git init
    echo "✓ Gitリポジトリを初期化しました"
fi
echo ""

# ステップ2: .gitignoreの作成
echo "ステップ2: .gitignoreの作成"
cat > .gitignore << 'EOF'
# SonarQube
.scannerwork/

# Docker
docker-compose.override.yml

# Python
__pycache__/
*.py[cod]
*$py.class
venv/
.env

# IDE
.vscode/
.idea/
*.swp
*.swo
EOF
echo "✓ .gitignoreを作成しました"
echo ""

# ステップ3: ファイルをステージング
echo "ステップ3: ファイルをステージング"
git add .
git status
echo ""

# ステップ4: コミット
echo "ステップ4: コミット"
git commit -m "Initial commit: SonarQube demo project"
echo ""

# ステップ5: GitHubリポジトリの作成指示
echo "=========================================="
echo "次の手順を実行してください:"
echo "=========================================="
echo ""
echo "1. GitHubでリポジトリを作成"
echo "   https://github.com/new"
echo "   - Repository name: sonar"
echo "   - Public or Private: どちらでも可"
echo "   - 「Create repository」をクリック"
echo ""
echo "2. リモートリポジトリを追加してpush"
echo "   git remote add origin https://github.com/YOUR_USERNAME/sonar.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "3. SonarCloudのセットアップ"
echo "   SONARCLOUD_SETUP.md を参照"
echo ""
