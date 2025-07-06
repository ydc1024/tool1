#!/bin/bash

# PHP Calculator Platform FastPanel 修复版部署脚本
# 修复 composer create-project 选项错误问题

set -e  # 遇到错误立即退出

echo "🚀 PHP Calculator Platform FastPanel 修复版部署脚本"
echo "================================================"
echo "目标域名: www.besthammer.club"
echo "目标目录: /var/www/besthammer_c_usr/data/www/besthammer.club"
echo "FastPanel环境: Ubuntu 24.04"
echo "修复: composer create-project 选项问题"
echo "================================================"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# 日志函数
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
    echo "使用方法: sudo bash fastpanel-deploy-fixed.sh"
    exit 1
fi

# 确认部署
echo "⚠️  此脚本将在FastPanel环境中部署PHP Calculator Platform"
echo "   目标目录: /var/www/besthammer_c_usr/data/www/besthammer.club"
echo ""
read -p "确认继续部署？(y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "部署已取消"
    exit 1
fi

echo ""
log_step "开始执行FastPanel修复版部署流程..."
echo ""

# 记录开始时间
START_TIME=$(date +%s)

# 第一步：环境检查
log_step "第1步：检查FastPanel环境..."

# 检查FastPanel用户目录
FASTPANEL_USER_DIR="/var/www/besthammer_c_usr"
FASTPANEL_WEB_DIR="/var/www/besthammer_c_usr/data/www"
PROJECT_DIR="/var/www/besthammer_c_usr/data/www/besthammer.club"

if [ ! -d "$FASTPANEL_USER_DIR" ]; then
    log_error "FastPanel用户目录不存在: $FASTPANEL_USER_DIR"
    log_error "请确保在FastPanel中已创建域名 besthammer.club"
    exit 1
fi

if [ ! -d "$FASTPANEL_WEB_DIR" ]; then
    log_error "FastPanel网站目录不存在: $FASTPANEL_WEB_DIR"
    exit 1
fi

log_success "FastPanel环境检查通过"

# 检查PHP版本
PHP_VERSION=$(php -v | head -n 1 | cut -d " " -f 2 | cut -d "." -f 1,2)
log_info "PHP版本: $PHP_VERSION"

# 检查Composer
if ! command -v composer &> /dev/null; then
    log_warning "Composer 未安装，正在安装..."
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
fi

COMPOSER_VERSION=$(composer --version | cut -d " " -f 3)
log_info "Composer版本: $COMPOSER_VERSION"

# 检查Node.js
if ! command -v node &> /dev/null; then
    log_warning "Node.js 未安装，正在安装..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
fi

NODE_VERSION=$(node --version)
log_info "Node.js版本: $NODE_VERSION"

log_success "环境检查完成"

# 第二步：创建项目目录
log_step "第2步：创建项目目录..."

# 如果目录存在，备份
if [ -d "$PROJECT_DIR" ]; then
    log_warning "目录已存在，创建备份..."
    mv "$PROJECT_DIR" "${PROJECT_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
fi

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

log_success "项目目录创建完成: $PROJECT_DIR"

# 第三步：创建Laravel项目（修复版）
log_step "第3步：创建Laravel项目（修复版）..."

# 方法1：先创建项目，再优化
log_info "正在创建Laravel项目..."
composer create-project laravel/laravel . "^10.0"

# 移除开发依赖并优化
log_info "移除开发依赖并优化autoloader..."
composer install --no-dev --optimize-autoloader

log_success "Laravel项目创建完成"

# 第四步：更新composer.json
log_step "第4步：更新项目依赖..."

cat > composer.json << 'EOF'
{
    "name": "tool1/php-calculator-platform",
    "type": "project",
    "description": "PHP工具类平台 - 贷款计算器 + BMI + 汇率转换器",
    "keywords": ["laravel", "calculator", "loan", "bmi", "currency", "converter"],
    "license": "MIT",
    "require": {
        "php": "^8.1",
        "guzzlehttp/guzzle": "^7.2",
        "laravel/framework": "^10.10",
        "laravel/sanctum": "^3.2",
        "laravel/tinker": "^2.8",
        "maatwebsite/excel": "^3.1",
        "barryvdh/laravel-dompdf": "^2.0"
    },
    "require-dev": {
        "fakerphp/faker": "^1.9.1",
        "laravel/pint": "^1.0",
        "laravel/sail": "^1.18",
        "mockery/mockery": "^1.4.4",
        "nunomaduro/collision": "^7.0",
        "phpunit/phpunit": "^10.1",
        "spatie/laravel-ignition": "^2.0"
    },
    "autoload": {
        "psr-4": {
            "App\\": "app/",
            "Database\\Factories\\": "database/factories/",
            "Database\\Seeders\\": "database/seeders/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "Tests\\": "tests/"
        }
    },
    "scripts": {
        "post-autoload-dump": [
            "Illuminate\\Foundation\\ComposerScripts::postAutoloadDump",
            "@php artisan package:discover --ansi"
        ],
        "post-update-cmd": [
            "@php artisan vendor:publish --tag=laravel-assets --ansi --force"
        ],
        "post-root-package-install": [
            "@php -r \"file_exists('.env') || copy('.env.example', '.env');\""
        ],
        "post-create-project-cmd": [
            "@php artisan key:generate --ansi"
        ]
    },
    "extra": {
        "laravel": {
            "dont-discover": []
        }
    },
    "config": {
        "optimize-autoloader": true,
        "preferred-install": "dist",
        "sort-packages": true,
        "allow-plugins": {
            "pestphp/pest-plugin": true,
            "php-http/discovery": true
        }
    },
    "minimum-stability": "stable",
    "prefer-stable": true
}
EOF

# 重新安装依赖
log_info "重新安装项目依赖..."
composer install --no-dev --optimize-autoloader

# 额外优化autoloader
composer dump-autoload --optimize --no-dev

log_success "项目依赖更新完成"

# 第五步：创建.env文件
log_step "第5步：配置环境变量..."

cat > .env << 'EOF'
APP_NAME="PHP Calculator Platform"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://www.besthammer.club

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=besthammer_c_usr
DB_USERNAME=besthammer_c_usr
DB_PASSWORD=

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MAIL_MAILER=smtp
MAIL_HOST=localhost
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@besthammer.club"
MAIL_FROM_NAME="${APP_NAME}"

# Multi-language settings
DEFAULT_LOCALE=en
AVAILABLE_LOCALES=en,es,fr,de

# API Keys for external services
EXCHANGE_RATE_API_KEY=
MORTGAGE_RATE_API_KEY=
PROPERTY_TAX_API_KEY=
EOF

# 生成应用密钥
php artisan key:generate

log_success "环境配置完成"

# 第六步：创建目录结构
log_step "第6步：创建项目目录结构..."

mkdir -p app/Http/Middleware
mkdir -p app/Services
mkdir -p resources/lang/{en,es,fr,de}
mkdir -p resources/views/{layouts,components}

log_success "目录结构创建完成"

# 第七步：验证安装
log_step "第7步：验证Laravel安装..."

# 检查artisan命令
if php artisan --version > /dev/null 2>&1; then
    log_success "Laravel安装验证成功"
    php artisan --version
else
    log_error "Laravel安装验证失败"
    exit 1
fi

# 计算部署时间
END_TIME=$(date +%s)
DEPLOY_TIME=$((END_TIME - START_TIME))

echo ""
log_success "🎉 FastPanel修复版基础部署完成！"
echo ""
echo "📊 部署统计:"
echo "   部署时间: ${DEPLOY_TIME} 秒"
echo "   项目目录: $PROJECT_DIR"
echo "   Laravel版本: $(php artisan --version 2>/dev/null || echo '获取失败')"
echo ""
log_info "接下来需要："
echo "1. 创建应用文件（中间件、控制器、视图等）"
echo "2. 在FastPanel中配置域名指向"
echo "3. 设置文件权限"
echo "4. 测试网站功能"
echo ""
log_info "请运行 fastpanel-create-files.sh 来完成应用文件创建..."
