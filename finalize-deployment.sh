#!/bin/bash

# PHP Calculator Platform 完成部署脚本
# 第四部分：设置权限、配置Nginx、完成部署

set -e

echo "🏁 完成部署配置..."

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

PROJECT_DIR="/var/www/besthammer.club"

# 第一步：设置文件权限
log_info "设置文件权限..."

# 设置所有者为www-data
chown -R www-data:www-data $PROJECT_DIR

# 设置基本权限
chmod -R 755 $PROJECT_DIR

# 设置存储和缓存目录权限
chmod -R 775 $PROJECT_DIR/storage
chmod -R 775 $PROJECT_DIR/bootstrap/cache

# 确保.env文件安全
chmod 600 $PROJECT_DIR/.env

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

# 第三步：创建Nginx配置
log_info "创建Nginx虚拟主机配置..."

cat > /etc/nginx/sites-available/besthammer.club << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name www.besthammer.club besthammer.club;
    
    # 重定向到HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name www.besthammer.club besthammer.club;
    
    root /var/www/besthammer.club/public;
    index index.php index.html index.htm;
    
    # SSL配置（Cloudflare代理模式）
    ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
    
    # SSL安全配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    # 安全头（适配Cloudflare）
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # 主要位置块
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    # PHP处理
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        
        # 确保HTTPS环境变量
        fastcgi_param HTTPS on;
        fastcgi_param HTTP_SCHEME https;
        
        # 增加超时时间
        fastcgi_read_timeout 300;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
    }
    
    # 静态文件缓存
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Vary Accept-Encoding;
        access_log off;
    }
    
    # 安全配置
    location ~ /\.(?!well-known).* {
        deny all;
    }
    
    location ~ /\.env {
        deny all;
    }
    
    location ~ /\.git {
        deny all;
    }
    
    # 禁止访问敏感文件
    location ~* \.(log|sql|conf)$ {
        deny all;
    }
    
    # Gzip压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript application/json;
    
    # 日志配置
    access_log /var/log/nginx/besthammer.club.access.log;
    error_log /var/log/nginx/besthammer.club.error.log;
}
EOF

# 启用站点
ln -sf /etc/nginx/sites-available/besthammer.club /etc/nginx/sites-enabled/

# 测试Nginx配置
nginx -t

if [ $? -eq 0 ]; then
    log_success "Nginx配置测试通过"
    systemctl reload nginx
    log_success "Nginx已重新加载"
else
    log_error "Nginx配置测试失败"
    exit 1
fi

# 第四步：创建测试脚本
log_info "创建测试脚本..."

cat > $PROJECT_DIR/test-deployment.sh << 'EOF'
#!/bin/bash

echo "🧪 开始测试部署..."

# 测试URL列表
URLS=(
    "https://www.besthammer.club/"
    "https://www.besthammer.club/en/"
    "https://www.besthammer.club/es/"
    "https://www.besthammer.club/fr/"
    "https://www.besthammer.club/de/"
)

for url in "${URLS[@]}"; do
    echo "测试: $url"
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    if [ "$response" = "200" ]; then
        echo "✅ $url - OK"
    else
        echo "❌ $url - HTTP $response"
    fi
done

echo ""
echo "🔍 检查Laravel日志..."
if [ -f "/var/www/besthammer.club/storage/logs/laravel.log" ]; then
    echo "最近的错误日志:"
    tail -n 10 /var/www/besthammer.club/storage/logs/laravel.log
else
    echo "✅ 没有发现错误日志"
fi

echo ""
echo "📊 系统状态:"
echo "PHP版本: $(php --version | head -n 1)"
echo "Nginx状态: $(systemctl is-active nginx)"
echo "磁盘使用: $(df -h /var/www | tail -n 1 | awk '{print $5}')"
echo "内存使用: $(free -h | grep Mem | awk '{print $3"/"$2}')"
EOF

chmod +x $PROJECT_DIR/test-deployment.sh

# 第五步：创建维护脚本
log_info "创建维护脚本..."

cat > $PROJECT_DIR/maintenance.sh << 'EOF'
#!/bin/bash

case "$1" in
    "logs")
        echo "📋 查看Laravel日志:"
        tail -f /var/www/besthammer.club/storage/logs/laravel.log
        ;;
    "clear-cache")
        echo "🧹 清除缓存..."
        cd /var/www/besthammer.club
        php artisan cache:clear
        php artisan config:clear
        php artisan route:clear
        php artisan view:clear
        echo "✅ 缓存已清除"
        ;;
    "optimize")
        echo "⚡ 优化应用..."
        cd /var/www/besthammer.club
        php artisan config:cache
        php artisan route:cache
        php artisan view:cache
        echo "✅ 应用已优化"
        ;;
    "status")
        echo "📊 系统状态:"
        systemctl status nginx --no-pager -l
        systemctl status php8.2-fpm --no-pager -l
        ;;
    *)
        echo "使用方法: $0 {logs|clear-cache|optimize|status}"
        ;;
esac
EOF

chmod +x $PROJECT_DIR/maintenance.sh

log_success "维护脚本创建完成"

# 第六步：最终检查
log_info "执行最终检查..."

# 检查PHP-FPM状态
if systemctl is-active --quiet php8.2-fpm; then
    log_success "PHP-FPM 运行正常"
else
    log_warning "PHP-FPM 可能有问题，正在重启..."
    systemctl restart php8.2-fpm
fi

# 检查Nginx状态
if systemctl is-active --quiet nginx; then
    log_success "Nginx 运行正常"
else
    log_warning "Nginx 可能有问题，正在重启..."
    systemctl restart nginx
fi

# 检查文件权限
if [ -w "$PROJECT_DIR/storage" ]; then
    log_success "存储目录权限正常"
else
    log_error "存储目录权限有问题"
fi

echo ""
echo "🎉 部署完成！"
echo ""
echo "📋 部署信息:"
echo "   网站地址: https://www.besthammer.club"
echo "   项目目录: $PROJECT_DIR"
echo "   Nginx配置: /etc/nginx/sites-available/besthammer.club"
echo ""
echo "🧪 测试命令:"
echo "   运行测试: $PROJECT_DIR/test-deployment.sh"
echo "   查看日志: $PROJECT_DIR/maintenance.sh logs"
echo "   清除缓存: $PROJECT_DIR/maintenance.sh clear-cache"
echo ""
echo "🌍 多语言URL测试:"
echo "   英语: https://www.besthammer.club/en/"
echo "   西班牙语: https://www.besthammer.club/es/"
echo "   法语: https://www.besthammer.club/fr/"
echo "   德语: https://www.besthammer.club/de/"
echo ""
log_info "请运行测试脚本验证部署是否成功！"
