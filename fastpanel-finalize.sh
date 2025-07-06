#!/bin/bash

# PHP Calculator Platform FastPanel 最终配置脚本
# 第四部分：创建多语言文件、配置路由、设置权限

set -e

echo "🏁 开始FastPanel最终配置..."

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

# 检查是否在正确的目录
if [ ! -f "artisan" ]; then
    log_error "请在Laravel项目根目录运行此脚本"
    exit 1
fi

PROJECT_DIR="/var/www/besthammer_c_usr/data/www/besthammer.club"

# 第一步：创建多语言文件
log_info "创建多语言文件..."

# 英语语言文件
mkdir -p resources/lang/en

cat > resources/lang/en/common.php << 'EOF'
<?php

return [
    // 网站通用文本
    'site_title' => 'PHP Calculator Platform',
    'site_description' => 'Professional financial and health calculators for loan, BMI, and currency conversion',
    
    // 导航菜单
    'nav' => [
        'home' => 'Home',
        'loan_calculator' => 'Loan Calculator',
        'bmi_calculator' => 'BMI Calculator',
        'currency_converter' => 'Currency Converter',
        'language' => 'Language',
    ],
    
    // 通用按钮和操作
    'buttons' => [
        'calculate' => 'Calculate',
        'reset' => 'Reset',
        'export' => 'Export',
        'download' => 'Download',
        'save' => 'Save',
        'cancel' => 'Cancel',
        'submit' => 'Submit',
        'back' => 'Back',
        'next' => 'Next',
        'previous' => 'Previous',
        'close' => 'Close',
        'edit' => 'Edit',
        'delete' => 'Delete',
        'view' => 'View',
        'compare' => 'Compare',
    ],
    
    // 页脚
    'footer' => [
        'copyright' => '© 2024 PHP Calculator Platform. All rights reserved.',
        'privacy' => 'Privacy Policy',
        'terms' => 'Terms of Service',
        'contact' => 'Contact Us',
        'about' => 'About',
    ],
];
EOF

cat > resources/lang/en/calculator.php << 'EOF'
<?php

return [
    // 贷款计算器
    'loan' => [
        'title' => 'Loan Calculator',
        'description' => 'Calculate monthly payments, total interest, and amortization schedules for your loan.',
        'monthly_payment' => 'Monthly Payment',
        'total_interest' => 'Total Interest',
        'amortization_schedule' => 'Amortization Schedule',
        'prepayment' => 'Prepayment Simulation',
    ],
    
    // BMI计算器
    'bmi' => [
        'title' => 'BMI Calculator',
        'description' => 'Calculate your Body Mass Index and get personalized health recommendations.',
        'bmi_result' => 'BMI Result',
        'bmr' => 'Basal Metabolic Rate (BMR)',
        'daily_calories' => 'Daily Calorie Needs',
        'macronutrients' => 'Macronutrients',
    ],
    
    // 汇率转换器
    'currency' => [
        'title' => 'Currency Converter',
        'description' => 'Convert currencies with real-time exchange rates and historical charts.',
        'exchange_rate' => 'Exchange Rate',
        'historical_chart' => 'Historical Chart',
        'batch_conversion' => 'Batch Conversion',
        'rate_alert' => 'Rate Alert',
    ],
];
EOF

# 西班牙语语言文件
mkdir -p resources/lang/es

cat > resources/lang/es/common.php << 'EOF'
<?php

return [
    'site_title' => 'Plataforma de Calculadoras PHP',
    'site_description' => 'Calculadoras profesionales financieras y de salud para préstamos, IMC y conversión de monedas',
    
    'nav' => [
        'home' => 'Inicio',
        'loan_calculator' => 'Calculadora de Préstamos',
        'bmi_calculator' => 'Calculadora de IMC',
        'currency_converter' => 'Conversor de Monedas',
        'language' => 'Idioma',
    ],
    
    'buttons' => [
        'calculate' => 'Calcular',
        'reset' => 'Reiniciar',
        'export' => 'Exportar',
        'download' => 'Descargar',
        'save' => 'Guardar',
        'cancel' => 'Cancelar',
        'submit' => 'Enviar',
        'back' => 'Atrás',
        'next' => 'Siguiente',
        'previous' => 'Anterior',
        'close' => 'Cerrar',
        'edit' => 'Editar',
        'delete' => 'Eliminar',
        'view' => 'Ver',
        'compare' => 'Comparar',
    ],
    
    'footer' => [
        'copyright' => '© 2024 Plataforma de Calculadoras PHP. Todos los derechos reservados.',
        'privacy' => 'Política de Privacidad',
        'terms' => 'Términos de Servicio',
        'contact' => 'Contáctanos',
        'about' => 'Acerca de',
    ],
];
EOF

cat > resources/lang/es/calculator.php << 'EOF'
<?php

return [
    'loan' => [
        'title' => 'Calculadora de Préstamos',
        'description' => 'Calcula pagos mensuales, interés total y cronogramas de amortización para tu préstamo.',
        'monthly_payment' => 'Pago Mensual',
        'total_interest' => 'Interés Total',
        'amortization_schedule' => 'Cronograma de Amortización',
        'prepayment' => 'Simulación de Prepago',
    ],
    
    'bmi' => [
        'title' => 'Calculadora de IMC',
        'description' => 'Calcula tu Índice de Masa Corporal y obtén recomendaciones de salud personalizadas.',
        'bmi_result' => 'Resultado del IMC',
        'bmr' => 'Tasa Metabólica Basal (TMB)',
        'daily_calories' => 'Necesidades Calóricas Diarias',
        'macronutrients' => 'Macronutrientes',
    ],
    
    'currency' => [
        'title' => 'Conversor de Monedas',
        'description' => 'Convierte monedas con tipos de cambio en tiempo real y gráficos históricos.',
        'exchange_rate' => 'Tipo de Cambio',
        'historical_chart' => 'Gráfico Histórico',
        'batch_conversion' => 'Conversión por Lotes',
        'rate_alert' => 'Alerta de Tipo de Cambio',
    ],
];
EOF

# 法语和德语语言文件（简化版本）
mkdir -p resources/lang/fr resources/lang/de

cp resources/lang/en/common.php resources/lang/fr/common.php
cp resources/lang/en/calculator.php resources/lang/fr/calculator.php
cp resources/lang/en/common.php resources/lang/de/common.php
cp resources/lang/en/calculator.php resources/lang/de/calculator.php

log_success "多语言文件创建完成"

# 第二步：配置路由
log_info "配置路由..."

cat > routes/web.php << 'EOF'
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\LanguageController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/

// 根路径重定向到默认语言
Route::get('/', function () {
    $locale = session('locale', config('app.locale'));
    return redirect("/{$locale}");
});

// 语言切换路由
Route::post('/language/switch', [LanguageController::class, 'switch'])->name('language.switch');

// 多语言路由组
Route::group([
    'prefix' => '{locale}',
    'middleware' => ['locale'],
    'where' => ['locale' => '[a-zA-Z]{2}']
], function () {
    
    // 首页
    Route::get('/', [HomeController::class, 'index'])->name('home');
    
    // 计算器路由（暂时指向首页，后续开发时替换）
    Route::get('/loan-calculator', [HomeController::class, 'index'])->name('loan.index');
    Route::get('/bmi-calculator', [HomeController::class, 'index'])->name('bmi.index');
    Route::get('/currency-converter', [HomeController::class, 'index'])->name('currency.index');
});
EOF

log_success "路由配置完成"

# 第三步：更新应用配置
log_info "更新应用配置..."

cat > config/app.php << 'EOF'
<?php

return [
    'name' => env('APP_NAME', 'PHP Calculator Platform'),
    'env' => env('APP_ENV', 'production'),
    'debug' => (bool) env('APP_DEBUG', false),
    'url' => env('APP_URL', 'http://localhost'),
    'asset_url' => env('ASSET_URL'),
    'timezone' => 'UTC',

    // 多语言配置
    'locale' => env('DEFAULT_LOCALE', 'en'),
    'fallback_locale' => 'en',
    'faker_locale' => 'en_US',

    // 支持的语言列表
    'available_locales' => [
        'en' => 'English',
        'es' => 'Español', 
        'fr' => 'Français',
        'de' => 'Deutsch'
    ],

    'key' => env('APP_KEY'),
    'cipher' => 'AES-256-CBC',

    'providers' => [
        Illuminate\Auth\AuthServiceProvider::class,
        Illuminate\Broadcasting\BroadcastServiceProvider::class,
        Illuminate\Bus\BusServiceProvider::class,
        Illuminate\Cache\CacheServiceProvider::class,
        Illuminate\Foundation\Providers\ConsoleSupportServiceProvider::class,
        Illuminate\Cookie\CookieServiceProvider::class,
        Illuminate\Database\DatabaseServiceProvider::class,
        Illuminate\Encryption\EncryptionServiceProvider::class,
        Illuminate\Filesystem\FilesystemServiceProvider::class,
        Illuminate\Foundation\Providers\FoundationServiceProvider::class,
        Illuminate\Hashing\HashServiceProvider::class,
        Illuminate\Mail\MailServiceProvider::class,
        Illuminate\Notifications\NotificationServiceProvider::class,
        Illuminate\Pagination\PaginationServiceProvider::class,
        Illuminate\Pipeline\PipelineServiceProvider::class,
        Illuminate\Queue\QueueServiceProvider::class,
        Illuminate\Redis\RedisServiceProvider::class,
        Illuminate\Auth\Passwords\PasswordResetServiceProvider::class,
        Illuminate\Session\SessionServiceProvider::class,
        Illuminate\Translation\TranslationServiceProvider::class,
        Illuminate\Validation\ValidationServiceProvider::class,
        Illuminate\View\ViewServiceProvider::class,

        // Package Service Providers
        Laravel\Sanctum\SanctumServiceProvider::class,

        // Application Service Providers
        App\Providers\AppServiceProvider::class,
        App\Providers\AuthServiceProvider::class,
        App\Providers\EventServiceProvider::class,
        App\Providers\RouteServiceProvider::class,
    ],

    'aliases' => [
        'App' => Illuminate\Support\Facades\App::class,
        'Arr' => Illuminate\Support\Arr::class,
        'Artisan' => Illuminate\Support\Facades\Artisan::class,
        'Auth' => Illuminate\Support\Facades\Auth::class,
        'Blade' => Illuminate\Support\Facades\Blade::class,
        'Broadcast' => Illuminate\Support\Facades\Broadcast::class,
        'Bus' => Illuminate\Support\Facades\Bus::class,
        'Cache' => Illuminate\Support\Facades\Cache::class,
        'Config' => Illuminate\Support\Facades\Config::class,
        'Cookie' => Illuminate\Support\Facades\Cookie::class,
        'Crypt' => Illuminate\Support\Facades\Crypt::class,
        'Date' => Illuminate\Support\Facades\Date::class,
        'DB' => Illuminate\Support\Facades\DB::class,
        'Eloquent' => Illuminate\Database\Eloquent\Model::class,
        'Event' => Illuminate\Support\Facades\Event::class,
        'File' => Illuminate\Support\Facades\File::class,
        'Gate' => Illuminate\Support\Facades\Gate::class,
        'Hash' => Illuminate\Support\Facades\Hash::class,
        'Http' => Illuminate\Support\Facades\Http::class,
        'Js' => Illuminate\Support\Js::class,
        'Lang' => Illuminate\Support\Facades\Lang::class,
        'Log' => Illuminate\Support\Facades\Log::class,
        'Mail' => Illuminate\Support\Facades\Mail::class,
        'Notification' => Illuminate\Support\Facades\Notification::class,
        'Password' => Illuminate\Support\Facades\Password::class,
        'Queue' => Illuminate\Support\Facades\Queue::class,
        'RateLimiter' => Illuminate\Support\Facades\RateLimiter::class,
        'Redirect' => Illuminate\Support\Facades\Redirect::class,
        'Request' => Illuminate\Support\Facades\Request::class,
        'Response' => Illuminate\Support\Facades\Response::class,
        'Route' => Illuminate\Support\Facades\Route::class,
        'Schema' => Illuminate\Support\Facades\Schema::class,
        'Session' => Illuminate\Support\Facades\Session::class,
        'Storage' => Illuminate\Support\Facades\Storage::class,
        'Str' => Illuminate\Support\Str::class,
        'URL' => Illuminate\Support\Facades\URL::class,
        'Validator' => Illuminate\Support\Facades\Validator::class,
        'View' => Illuminate\Support\Facades\View::class,
    ],
];
EOF

log_success "应用配置更新完成"

# 第四步：注册中间件
log_info "注册中间件..."

# 更新Kernel.php以注册LocaleMiddleware
if [ -f "app/Http/Kernel.php" ]; then
    # 备份原文件
    cp app/Http/Kernel.php app/Http/Kernel.php.backup
    
    # 添加中间件到路由中间件组
    sed -i "/protected \$middlewareAliases = \[/a\\        'locale' => \\App\\Http\\Middleware\\LocaleMiddleware::class," app/Http/Kernel.php
fi

log_success "中间件注册完成"

echo ""
log_success "🎉 FastPanel最终配置完成！"
echo ""
log_info "接下来需要："
echo "1. 设置文件权限"
echo "2. 配置Laravel缓存"
echo "3. 创建测试脚本"
echo ""
log_info "请运行 fastpanel-permissions.sh 来完成权限设置..."
