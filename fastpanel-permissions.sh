#!/bin/bash

# PHP Calculator Platform FastPanel 权限设置脚本
# 第五部分：设置文件权限、Laravel配置、创建测试脚本

set -e

echo "🔐 开始设置FastPanel权限和最终配置..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    log_error "请使用 root 用户或 sudo 运行此脚本"
    exit 1
fi

# 检查是否在正确的目录
if [ ! -f "artisan" ]; then
    log_error "请在Laravel项目根目录运行此脚本"
    exit 1
fi

PROJECT_DIR="/var/www/besthammer_c_usr/data/www/besthammer.club"

# 第一步：设置文件权限
log_info "设置FastPanel文件权限..."

# 获取FastPanel用户和组
FASTPANEL_USER="besthammer_c_usr"
FASTPANEL_GROUP="besthammer_c_usr"

# 检查用户是否存在
if ! id "$FASTPANEL_USER" &>/dev/null; then
    log_warning "FastPanel用户 $FASTPANEL_USER 不存在，使用 www-data"
    FASTPANEL_USER="www-data"
    FASTPANEL_GROUP="www-data"
fi

# 设置所有者
chown -R $FASTPANEL_USER:$FASTPANEL_GROUP $PROJECT_DIR

# 设置基本权限
chmod -R 755 $PROJECT_DIR

# 设置存储和缓存目录权限
chmod -R 775 $PROJECT_DIR/storage
chmod -R 775 $PROJECT_DIR/bootstrap/cache

# 确保.env文件安全
chmod 600 $PROJECT_DIR/.env

# 设置日志目录权限
mkdir -p $PROJECT_DIR/storage/logs
chmod -R 775 $PROJECT_DIR/storage/logs

log_success "文件权限设置完成"

# 第二步：Laravel配置
log_info "执行Laravel配置命令..."

cd $PROJECT_DIR

# 创建存储链接
php artisan storage:link

# 清除所有缓存
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# 优化生产环境
php artisan config:cache
php artisan route:cache
php artisan view:cache

log_success "Laravel配置完成"

# 第三步：创建测试脚本
log_info "创建测试脚本..."

cat > $PROJECT_DIR/test-fastpanel.sh << 'EOF'
#!/bin/bash

echo "🧪 开始测试FastPanel部署..."

# 测试URL列表
URLS=(
    "https://www.besthammer.club/"
    "https://www.besthammer.club/en/"
    "https://www.besthammer.club/es/"
    "https://www.besthammer.club/fr/"
    "https://www.besthammer.club/de/"
)

echo "📡 测试网站访问..."
for url in "${URLS[@]}"; do
    echo "测试: $url"
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" --connect-timeout 10 || echo "000")
    if [ "$response" = "200" ]; then
        echo "✅ $url - OK"
    else
        echo "❌ $url - HTTP $response"
    fi
done

echo ""
echo "🔍 检查Laravel日志..."
if [ -f "/var/www/besthammer_c_usr/data/www/besthammer.club/storage/logs/laravel.log" ]; then
    echo "最近的错误日志:"
    tail -n 10 /var/www/besthammer_c_usr/data/www/besthammer.club/storage/logs/laravel.log
else
    echo "✅ 没有发现错误日志"
fi

echo ""
echo "📊 系统状态:"
echo "PHP版本: $(php --version | head -n 1)"
echo "磁盘使用: $(df -h /var/www | tail -n 1 | awk '{print $5}' 2>/dev/null || echo 'N/A')"
echo "内存使用: $(free -h | grep Mem | awk '{print $3"/"$2}' 2>/dev/null || echo 'N/A')"

echo ""
echo "🔧 Laravel状态检查:"
cd /var/www/besthammer_c_usr/data/www/besthammer.club

echo "应用密钥: $(php artisan tinker --execute='echo config("app.key") ? "已设置" : "未设置";' 2>/dev/null || echo '检查失败')"
echo "缓存状态: $(php artisan config:show app.name 2>/dev/null && echo '缓存正常' || echo '缓存异常')"

echo ""
echo "📁 文件权限检查:"
echo "项目目录权限: $(stat -c '%a' /var/www/besthammer_c_usr/data/www/besthammer.club)"
echo "存储目录权限: $(stat -c '%a' /var/www/besthammer_c_usr/data/www/besthammer.club/storage)"
echo ".env文件权限: $(stat -c '%a' /var/www/besthammer_c_usr/data/www/besthammer.club/.env)"

echo ""
echo "🎯 FastPanel部署测试完成！"
EOF

chmod +x $PROJECT_DIR/test-fastpanel.sh

log_success "测试脚本创建完成"

# 第四步：创建维护脚本
log_info "创建维护脚本..."

cat > $PROJECT_DIR/maintenance-fastpanel.sh << 'EOF'
#!/bin/bash

# FastPanel维护脚本

PROJECT_DIR="/var/www/besthammer_c_usr/data/www/besthammer.club"

case "$1" in
    "logs")
        echo "📋 查看Laravel日志..."
        if [ -f "$PROJECT_DIR/storage/logs/laravel.log" ]; then
            tail -n 50 "$PROJECT_DIR/storage/logs/laravel.log"
        else
            echo "没有找到日志文件"
        fi
        ;;
    "clear-cache")
        echo "🧹 清除Laravel缓存..."
        cd "$PROJECT_DIR"
        php artisan config:clear
        php artisan cache:clear
        php artisan route:clear
        php artisan view:clear
        echo "缓存清除完成"
        ;;
    "optimize")
        echo "⚡ 优化Laravel应用..."
        cd "$PROJECT_DIR"
        php artisan config:cache
        php artisan route:cache
        php artisan view:cache
        echo "应用优化完成"
        ;;
    "status")
        echo "📊 FastPanel应用状态..."
        cd "$PROJECT_DIR"
        echo "应用名称: $(php artisan tinker --execute='echo config("app.name");' 2>/dev/null || echo '获取失败')"
        echo "应用环境: $(php artisan tinker --execute='echo config("app.env");' 2>/dev/null || echo '获取失败')"
        echo "调试模式: $(php artisan tinker --execute='echo config("app.debug") ? "开启" : "关闭";' 2>/dev/null || echo '获取失败')"
        echo "应用URL: $(php artisan tinker --execute='echo config("app.url");' 2>/dev/null || echo '获取失败')"
        ;;
    "permissions")
        echo "🔐 重新设置文件权限..."
        FASTPANEL_USER="besthammer_c_usr"
        if ! id "$FASTPANEL_USER" &>/dev/null; then
            FASTPANEL_USER="www-data"
        fi
        chown -R $FASTPANEL_USER:$FASTPANEL_USER "$PROJECT_DIR"
        chmod -R 755 "$PROJECT_DIR"
        chmod -R 775 "$PROJECT_DIR/storage"
        chmod -R 775 "$PROJECT_DIR/bootstrap/cache"
        chmod 600 "$PROJECT_DIR/.env"
        echo "文件权限设置完成"
        ;;
    *)
        echo "FastPanel维护脚本使用方法:"
        echo "  $0 logs          - 查看应用日志"
        echo "  $0 clear-cache   - 清除应用缓存"
        echo "  $0 optimize      - 优化应用性能"
        echo "  $0 status        - 查看应用状态"
        echo "  $0 permissions   - 重新设置文件权限"
        ;;
esac
EOF

chmod +x $PROJECT_DIR/maintenance-fastpanel.sh

log_success "维护脚本创建完成"

# 第五步：最终检查
log_info "执行最终检查..."

# 检查关键文件是否存在
REQUIRED_FILES=(
    "artisan"
    ".env"
    "app/Http/Controllers/HomeController.php"
    "app/Http/Controllers/LanguageController.php"
    "app/Http/Middleware/LocaleMiddleware.php"
    "resources/views/layouts/app.blade.php"
    "resources/views/home.blade.php"
    "resources/lang/en/common.php"
    "routes/web.php"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$PROJECT_DIR/$file" ]; then
        echo "✅ $file"
    else
        log_error "❌ 缺少文件: $file"
    fi
done

# 检查目录权限
if [ -w "$PROJECT_DIR/storage" ]; then
    log_success "存储目录权限正常"
else
    log_error "存储目录权限有问题"
fi

echo ""
echo "🎉 FastPanel部署完成！"
echo "================================================"
echo "📋 部署信息:"
echo "   网站地址: https://www.besthammer.club"
echo "   项目目录: $PROJECT_DIR"
echo "   FastPanel用户: $FASTPANEL_USER"
echo ""
echo "🧪 测试命令:"
echo "   运行测试: $PROJECT_DIR/test-fastpanel.sh"
echo "   查看日志: $PROJECT_DIR/maintenance-fastpanel.sh logs"
echo "   清除缓存: $PROJECT_DIR/maintenance-fastpanel.sh clear-cache"
echo "   优化应用: $PROJECT_DIR/maintenance-fastpanel.sh optimize"
echo ""
echo "🌍 多语言URL测试:"
echo "   英语: https://www.besthammer.club/en/"
echo "   西班牙语: https://www.besthammer.club/es/"
echo "   法语: https://www.besthammer.club/fr/"
echo "   德语: https://www.besthammer.club/de/"
echo ""
echo "📝 下一步建议:"
echo "   1. 在FastPanel中配置域名指向项目目录"
echo "   2. 配置SSL证书"
echo "   3. 运行测试脚本验证部署"
echo "   4. 开始开发计算器功能模块"
echo ""
log_success "PHP Calculator Platform FastPanel部署成功！"
