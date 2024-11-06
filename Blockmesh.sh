#!/bin/bash

# 检查是否以 root 用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以 root 用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到 root 用户，然后再次运行此脚本。"
    exit 1
fi

# 更新系统并安装必要的依赖
echo "更新系统并安装依赖包..."
sudo apt update -y
sudo apt install -y wget tar curl python3 python3-pip

# 检查并安装 Docker（如果需要 Docker 环境）
if ! command -v docker &> /dev/null; then
    echo "安装 Docker..."
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# 检查并安装 Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "安装 Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# 下载和解压 BlockMesh CLI
echo "下载 BlockMesh CLI..."
wget https://github.com/block-mesh/block-mesh-monorepo/releases/download/v0.0.343/blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz

echo "解压 BlockMesh CLI..."
tar -xvzf blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz -C /tmp
mkdir -p ~/target/release
mv /tmp/blockmesh-cli ~/target/release/

# 赋予执行权限
cd ~/target/release
chmod +x blockmesh-cli

# 获取用户邮箱和密码
read -p "请输入您的 BlockMesh 邮箱: " email
read -s -p "请输入您的 BlockMesh 密码: " password
echo

# 启动 BlockMesh CLI 并将日志输出到 blockmesh.log
echo "启动 BlockMesh CLI..."
nohup ./blockmesh-cli --email "$email" --password "$password" > blockmesh.log 2>&1 &

echo "BlockMesh CLI 已在后台运行，日志文件为 ~/target/release/blockmesh.log"
