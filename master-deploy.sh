#!/bin/bash

# PHP Calculator Platform 主部署脚本
# 一键完成所有部署步骤

set -e

echo "🚀 PHP Calculator Platform 一键部署脚本"
echo "================================================"
echo "目标服务器: 104.194.77.132"
echo "域名: www.besthammer.club"
echo "操作系统: Ubuntu 24.04.2 LTS"
echo "面板: FastPanel 2025-05-22"
echo "================================================"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    log_error "请使用 root 用户或 sudo 运行此脚本"
    echo "使用方法: sudo bash master-deploy.sh"
    exit 1
fi

# 确认部署
echo "⚠️  此脚本将："
echo "   1. 创建Laravel项目在 /var/www/besthammer.club"
echo "   2. 配置数据库连接"
echo "   3. 设置Nginx虚拟主机"
echo "   4. 配置SSL和安全设置"
echo "   5. 部署多语言支持系统"
echo ""
read -p "确认继续部署？(y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "部署已取消"
    exit 1
fi

echo ""
log_step "开始执行部署流程..."
echo ""

# 记录开始时间
START_TIME=$(date +%s)

# 第一步：基础部署
log_step "第1步：执行基础部署 (deploy.sh)"
if [ -f "deploy.sh" ]; then
    chmod +x deploy.sh
    ./deploy.sh
    log_success "基础部署完成"
else
    log_error "deploy.sh 文件不存在"
    exit 1
fi

echo ""

# 第二步：创建应用文件
log_step "第2步：创建应用文件 (create-app-files.sh)"
cd /var/www/besthammer.club

# 复制脚本到项目目录
cp /root/create-app-files.sh .
chmod +x create-app-files.sh
./create-app-files.sh
log_success "应用文件创建完成"

echo ""

# 第三步：创建视图文件
log_step "第3步：创建视图文件 (create-views.sh)"
cp /root/create-views.sh .
chmod +x create-views.sh
./create-views.sh
log_success "视图文件创建完成"

echo ""

# 第四步：完成部署配置
log_step "第4步：完成部署配置 (finalize-deployment.sh)"
cp /root/finalize-deployment.sh .
chmod +x finalize-deployment.sh
./finalize-deployment.sh
log_success "部署配置完成"

echo ""

# 第五步：执行测试
log_step "第5步：执行部署测试"
sleep 3  # 等待服务启动

echo "正在测试网站访问..."
./test-deployment.sh

echo ""

# 计算部署时间
END_TIME=$(date +%s)
DEPLOY_TIME=$((END_TIME - START_TIME))

echo "🎉 部署完成！"
echo "================================================"
echo "📊 部署统计:"
echo "   部署时间: ${DEPLOY_TIME} 秒"
echo "   项目目录: /var/www/besthammer.club"
echo "   网站地址: https://www.besthammer.club"
echo ""
echo "🌍 多语言测试URL:"
echo "   英语 (默认): https://www.besthammer.club/en/"
echo "   西班牙语:     https://www.besthammer.club/es/"
echo "   法语:         https://www.besthammer.club/fr/"
echo "   德语:         https://www.besthammer.club/de/"
echo ""
echo "🛠️ 维护命令:"
echo "   查看日志:     ./maintenance.sh logs"
echo "   清除缓存:     ./maintenance.sh clear-cache"
echo "   优化应用:     ./maintenance.sh optimize"
echo "   系统状态:     ./maintenance.sh status"
echo ""
echo "📋 下一步建议:"
echo "   1. 在浏览器中访问 https://www.besthammer.club"
echo "   2. 测试多语言切换功能"
echo "   3. 检查移动端响应式设计"
echo "   4. 验证Cloudflare代理设置"
echo "   5. 开始开发计算器功能模块"
echo ""
log_success "PHP Calculator Platform 部署成功！"
