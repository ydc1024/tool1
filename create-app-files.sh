#!/bin/bash

# PHP Calculator Platform 应用文件创建脚本
# 第二部分：创建所有应用文件

set -e

echo "🔧 开始创建应用文件..."

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

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否在正确的目录
if [ ! -f "artisan" ]; then
    log_error "请在Laravel项目根目录运行此脚本"
    exit 1
fi

# 第一步：创建中间件
log_info "创建LocaleMiddleware..."

cat > app/Http/Middleware/LocaleMiddleware.php << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\Session;

class LocaleMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        $availableLocales = ['en', 'es', 'fr', 'de'];
        $locale = $request->segment(1);
        
        if (!$locale || !in_array($locale, $availableLocales)) {
            $locale = Session::get('locale');
            
            if (!$locale || !in_array($locale, $availableLocales)) {
                $locale = $this->detectBrowserLanguage($request, $availableLocales);
            }
            
            if (!$locale || !in_array($locale, $availableLocales)) {
                $locale = 'en';
            }
            
            if ($request->getPathInfo() !== '/') {
                return redirect("/{$locale}" . $request->getRequestUri());
            }
        }
        
        App::setLocale($locale);
        Session::put('locale', $locale);
        
        return $next($request);
    }
    
    private function detectBrowserLanguage(Request $request, array $availableLocales): ?string
    {
        $acceptLanguage = $request->header('Accept-Language');
        
        if (!$acceptLanguage) {
            return null;
        }
        
        $languages = [];
        foreach (explode(',', $acceptLanguage) as $lang) {
            $parts = explode(';', trim($lang));
            $code = trim($parts[0]);
            $quality = 1.0;
            
            if (isset($parts[1]) && strpos($parts[1], 'q=') === 0) {
                $quality = (float) substr($parts[1], 2);
            }
            
            $code = substr($code, 0, 2);
            $languages[$code] = $quality;
        }
        
        arsort($languages);
        
        foreach (array_keys($languages) as $lang) {
            if (in_array($lang, $availableLocales)) {
                return $lang;
            }
        }
        
        return null;
    }
}
EOF

# 第二步：更新Kernel.php
log_info "更新Kernel.php..."

cat > app/Http/Kernel.php << 'EOF'
<?php

namespace App\Http;

use Illuminate\Foundation\Http\Kernel as HttpKernel;

class Kernel extends HttpKernel
{
    protected $middleware = [
        \App\Http\Middleware\TrustProxies::class,
        \Illuminate\Http\Middleware\HandleCors::class,
        \App\Http\Middleware\PreventRequestsDuringMaintenance::class,
        \Illuminate\Foundation\Http\Middleware\ValidatePostSize::class,
        \App\Http\Middleware\TrimStrings::class,
        \Illuminate\Foundation\Http\Middleware\ConvertEmptyStringsToNull::class,
    ];

    protected $middlewareGroups = [
        'web' => [
            \App\Http\Middleware\EncryptCookies::class,
            \Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse::class,
            \Illuminate\Session\Middleware\StartSession::class,
            \Illuminate\View\Middleware\ShareErrorsFromSession::class,
            \App\Http\Middleware\VerifyCsrfToken::class,
            \Illuminate\Routing\Middleware\SubstituteBindings::class,
        ],
        'api' => [
            \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
            \Illuminate\Routing\Middleware\ThrottleRequests::class.':api',
            \Illuminate\Routing\Middleware\SubstituteBindings::class,
        ],
    ];

    protected $middlewareAliases = [
        'auth' => \App\Http\Middleware\Authenticate::class,
        'auth.basic' => \Illuminate\Auth\Middleware\AuthenticateWithBasicAuth::class,
        'cache.headers' => \Illuminate\Http\Middleware\SetCacheHeaders::class,
        'can' => \Illuminate\Auth\Middleware\Authorize::class,
        'guest' => \App\Http\Middleware\RedirectIfAuthenticated::class,
        'password.confirm' => \Illuminate\Auth\Middleware\RequirePassword::class,
        'signed' => \App\Http\Middleware\ValidateSignature::class,
        'throttle' => \Illuminate\Routing\Middleware\ThrottleRequests::class,
        'verified' => \Illuminate\Auth\Middleware\EnsureEmailIsVerified::class,
        'locale' => \App\Http\Middleware\LocaleMiddleware::class,
    ];
}
EOF

# 第三步：创建控制器
log_info "创建HomeController..."

cat > app/Http/Controllers/HomeController.php << 'EOF'
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\View\View;

class HomeController extends Controller
{
    public function index(Request $request): View
    {
        $locale = $request->route('locale') ?? app()->getLocale();
        
        $calculators = [
            [
                'name' => 'Loan Calculator',
                'description' => 'Calculate monthly payments, total interest, and amortization schedules.',
                'icon' => 'calculator',
                'color' => 'blue',
            ],
            [
                'name' => 'BMI Calculator', 
                'description' => 'Calculate BMI and get personalized health recommendations.',
                'icon' => 'heart',
                'color' => 'green',
            ],
            [
                'name' => 'Currency Converter',
                'description' => 'Convert currencies with real-time exchange rates.',
                'icon' => 'currency-dollar',
                'color' => 'purple',
            ],
        ];
        
        $stats = [
            'total_calculations' => 125000,
            'active_users' => 15000,
            'supported_currencies' => 150,
            'languages_supported' => 4,
        ];
        
        return view('home', compact('calculators', 'stats', 'locale'));
    }
}
EOF

# 第四步：创建语言控制器
log_info "创建LanguageController..."

cat > app/Http/Controllers/LanguageController.php << 'EOF'
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Session;

class LanguageController extends Controller
{
    public function switch(Request $request): RedirectResponse
    {
        $locale = $request->input('locale');
        $availableLocales = ['en', 'es', 'fr', 'de'];
        
        if (!in_array($locale, $availableLocales)) {
            return back()->with('error', 'Invalid language selected.');
        }
        
        Session::put('locale', $locale);
        
        $currentPath = $request->input('current_path', '/');
        $pathSegments = explode('/', trim($currentPath, '/'));
        
        if (count($pathSegments) > 0 && in_array($pathSegments[0], $availableLocales)) {
            $pathSegments[0] = $locale;
        } else {
            array_unshift($pathSegments, $locale);
        }
        
        $newPath = '/' . implode('/', $pathSegments);
        
        return redirect($newPath)->with('success', 'Language changed successfully.');
    }
}
EOF

# 第五步：更新路由
log_info "更新路由文件..."

cat > routes/web.php << 'EOF'
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\LanguageController;

// 根路径重定向到默认语言
Route::get('/', function () {
    $locale = session('locale', 'en');
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
    Route::get('/', [HomeController::class, 'index'])->name('home');
});
EOF

log_success "应用文件创建完成！"
echo ""
log_info "接下来运行第三个脚本来创建视图文件..."
