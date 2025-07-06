#!/bin/bash

# PHP Calculator Platform FastPanel 主部署脚本
# 一键完成FastPanel环境下的所有部署步骤

set -e

echo "🚀 PHP Calculator Platform FastPanel 一键部署脚本"
echo "================================================"
echo "目标服务器: FastPanel环境"
echo "域名: www.besthammer.club"
echo "目标目录: /var/www/besthammer_c_usr/data/www/besthammer.club"
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
    echo "使用方法: sudo bash fastpanel-master-deploy.sh"
    exit 1
fi

# 确认部署
echo "⚠️  此脚本将在FastPanel环境中部署PHP Calculator Platform："
echo "   1. 创建Laravel项目在 /var/www/besthammer_c_usr/data/www/besthammer.club"
echo "   2. 配置多语言支持系统"
echo "   3. 创建基础控制器和视图"
echo "   4. 设置FastPanel适配的文件权限"
echo "   5. 创建测试和维护脚本"
echo ""
read -p "确认继续部署？(y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "部署已取消"
    exit 1
fi

echo ""
log_step "开始执行FastPanel部署流程..."
echo ""

# 记录开始时间
START_TIME=$(date +%s)

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 第一步：基础部署
log_step "第1步：执行基础部署 (fastpanel-deploy.sh)"
if [ -f "$SCRIPT_DIR/fastpanel-deploy.sh" ]; then
    chmod +x "$SCRIPT_DIR/fastpanel-deploy.sh"
    bash "$SCRIPT_DIR/fastpanel-deploy.sh"
    log_success "基础部署完成"
else
    log_error "fastpanel-deploy.sh 文件不存在"
    exit 1
fi

echo ""

# 第二步：创建应用文件
log_step "第2步：创建应用文件 (fastpanel-create-files.sh)"
cd /var/www/besthammer_c_usr/data/www/besthammer.club

# 复制脚本到项目目录
if [ -f "$SCRIPT_DIR/fastpanel-create-files.sh" ]; then
    cp "$SCRIPT_DIR/fastpanel-create-files.sh" .
    chmod +x fastpanel-create-files.sh
    bash ./fastpanel-create-files.sh
    log_success "应用文件创建完成"
else
    log_error "fastpanel-create-files.sh 文件不存在"
    exit 1
fi

echo ""

# 第三步：创建视图文件
log_step "第3步：创建视图文件 (fastpanel-create-views.sh)"
if [ -f "$SCRIPT_DIR/fastpanel-create-views.sh" ]; then
    cp "$SCRIPT_DIR/fastpanel-create-views.sh" .
    chmod +x fastpanel-create-views.sh
    bash ./fastpanel-create-views.sh
    log_success "视图文件创建完成"
else
    log_error "fastpanel-create-views.sh 文件不存在"
    exit 1
fi

echo ""

# 第四步：最终配置
log_step "第4步：最终配置 (fastpanel-finalize.sh)"
if [ -f "$SCRIPT_DIR/fastpanel-finalize.sh" ]; then
    cp "$SCRIPT_DIR/fastpanel-finalize.sh" .
    chmod +x fastpanel-finalize.sh
    bash ./fastpanel-finalize.sh
    log_success "最终配置完成"
else
    log_error "fastpanel-finalize.sh 文件不存在"
    exit 1
fi

echo ""

# 第五步：权限设置
log_step "第5步：权限设置 (fastpanel-permissions.sh)"
if [ -f "$SCRIPT_DIR/fastpanel-permissions.sh" ]; then
    cp "$SCRIPT_DIR/fastpanel-permissions.sh" .
    chmod +x fastpanel-permissions.sh
    bash ./fastpanel-permissions.sh
    log_success "权限设置完成"
else
    log_error "fastpanel-permissions.sh 文件不存在"
    exit 1
fi

echo ""

# 第六步：执行测试
log_step "第6步：执行部署测试"
sleep 3  # 等待服务启动

echo "正在测试网站访问..."
if [ -f "./test-fastpanel.sh" ]; then
    bash ./test-fastpanel.sh
else
    log_warning "测试脚本不存在，跳过自动测试"
fi

echo ""

# 计算部署时间
END_TIME=$(date +%s)
DEPLOY_TIME=$((END_TIME - START_TIME))

echo "🎉 FastPanel部署完成！"
echo "================================================"
echo "📊 部署统计:"
echo "   部署时间: ${DEPLOY_TIME} 秒"
echo "   项目目录: /var/www/besthammer_c_usr/data/www/besthammer.club"
echo "   网站地址: https://www.besthammer.club"
echo ""
echo "🌍 多语言测试URL:"
echo "   英语 (默认): https://www.besthammer.club/en/"
echo "   西班牙语:     https://www.besthammer.club/es/"
echo "   法语:         https://www.besthammer.club/fr/"
echo "   德语:         https://www.besthammer.club/de/"
echo ""
echo "🛠️ 维护命令:"
echo "   查看日志:     ./maintenance-fastpanel.sh logs"
echo "   清除缓存:     ./maintenance-fastpanel.sh clear-cache"
echo "   优化应用:     ./maintenance-fastpanel.sh optimize"
echo "   系统状态:     ./maintenance-fastpanel.sh status"
echo "   重设权限:     ./maintenance-fastpanel.sh permissions"
echo ""
echo "📋 FastPanel配置提醒:"
echo "   1. 在FastPanel中确保域名 besthammer.club 指向正确目录"
echo "   2. 配置SSL证书（推荐Let's Encrypt）"
echo "   3. 检查PHP版本和扩展（建议PHP 8.1+）"
echo "   4. 配置数据库连接（如需要）"
echo ""
echo "🧪 测试步骤:"
echo "   1. 运行: ./test-fastpanel.sh"
echo "   2. 在浏览器中访问 https://www.besthammer.club"
echo "   3. 测试多语言切换功能"
echo "   4. 检查移动端响应式设计"
echo ""
echo "📝 下一步开发:"
echo "   1. 基础框架测试通过后"
echo "   2. 开发贷款计算器功能"
echo "   3. 开发BMI计算器功能"
echo "   4. 开发汇率转换器功能"
echo "   5. 集成外部API服务"
echo ""
log_success "PHP Calculator Platform FastPanel部署成功！"
echo ""
log_info "请在FastPanel面板中配置域名指向，然后运行测试脚本验证部署！"
