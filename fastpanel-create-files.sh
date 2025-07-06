#!/bin/bash

# PHP Calculator Platform FastPanel 应用文件创建脚本
# 第二部分：创建所有应用文件

set -e

echo "🔧 开始创建FastPanel应用文件..."

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
    log_error "当前目录应该是: /var/www/besthammer_c_usr/data/www/besthammer.club"
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
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next)
    {
        // 获取可用语言列表
        $availableLocales = array_keys(config('app.available_locales'));
        
        // 从URL路径中获取语言代码
        $locale = $request->segment(1);
        
        // 如果URL中没有语言代码或语言代码无效
        if (!$locale || !in_array($locale, $availableLocales)) {
            // 尝试从session获取
            $locale = Session::get('locale');
            
            // 如果session中也没有，尝试从浏览器语言获取
            if (!$locale || !in_array($locale, $availableLocales)) {
                $locale = $this->detectBrowserLanguage($request, $availableLocales);
            }
            
            // 如果还是没有，使用默认语言
            if (!$locale || !in_array($locale, $availableLocales)) {
                $locale = config('app.locale');
            }
            
            // 重定向到带语言前缀的URL
            if ($request->getPathInfo() !== '/') {
                return redirect("/{$locale}" . $request->getRequestUri());
            }
        }
        
        // 设置应用语言
        App::setLocale($locale);
        Session::put('locale', $locale);
        
        return $next($request);
    }
    
    /**
     * 检测浏览器首选语言
     */
    private function detectBrowserLanguage(Request $request, array $availableLocales): ?string
    {
        $acceptLanguage = $request->header('Accept-Language');
        
        if (!$acceptLanguage) {
            return null;
        }
        
        // 解析Accept-Language头
        $languages = [];
        foreach (explode(',', $acceptLanguage) as $lang) {
            $parts = explode(';', trim($lang));
            $code = trim($parts[0]);
            $quality = 1.0;
            
            if (isset($parts[1]) && strpos($parts[1], 'q=') === 0) {
                $quality = (float) substr($parts[1], 2);
            }
            
            // 只取语言代码的前两位
            $code = substr($code, 0, 2);
            $languages[$code] = $quality;
        }
        
        // 按质量排序
        arsort($languages);
        
        // 找到第一个支持的语言
        foreach (array_keys($languages) as $lang) {
            if (in_array($lang, $availableLocales)) {
                return $lang;
            }
        }
        
        return null;
    }
}
EOF

log_success "LocaleMiddleware 创建完成"

# 第二步：创建控制器
log_info "创建控制器..."

# HomeController
cat > app/Http/Controllers/HomeController.php << 'EOF'
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\View\View;

class HomeController extends Controller
{
    /**
     * 显示首页
     */
    public function index(Request $request): View
    {
        $locale = $request->route('locale');
        
        // 获取当前语言的配置
        $currentLanguage = config('app.available_locales')[$locale] ?? 'English';
        
        // 准备首页数据
        $calculators = [
            [
                'name' => __('calculator.loan.title'),
                'description' => __('calculator.loan.description'),
                'icon' => 'calculator',
                'route' => route('loan.index', ['locale' => $locale]),
                'color' => 'blue',
                'features' => [
                    __('calculator.loan.monthly_payment'),
                    __('calculator.loan.total_interest'),
                    __('calculator.loan.amortization_schedule'),
                    __('calculator.loan.prepayment'),
                ]
            ],
            [
                'name' => __('calculator.bmi.title'),
                'description' => __('calculator.bmi.description'),
                'icon' => 'heart',
                'route' => route('bmi.index', ['locale' => $locale]),
                'color' => 'green',
                'features' => [
                    __('calculator.bmi.bmi_result'),
                    __('calculator.bmi.bmr'),
                    __('calculator.bmi.daily_calories'),
                    __('calculator.bmi.macronutrients'),
                ]
            ],
            [
                'name' => __('calculator.currency.title'),
                'description' => __('calculator.currency.description'),
                'icon' => 'currency-dollar',
                'route' => route('currency.index', ['locale' => $locale]),
                'color' => 'purple',
                'features' => [
                    __('calculator.currency.exchange_rate'),
                    __('calculator.currency.historical_chart'),
                    __('calculator.currency.batch_conversion'),
                    __('calculator.currency.rate_alert'),
                ]
            ],
        ];
        
        // 统计数据（可以从数据库获取）
        $stats = [
            'total_calculations' => 125000,
            'active_users' => 15000,
            'supported_currencies' => 150,
            'languages_supported' => count(config('app.available_locales')),
        ];
        
        return view('home', compact('calculators', 'stats', 'currentLanguage', 'locale'));
    }
}
EOF

# LanguageController
cat > app/Http/Controllers/LanguageController.php << 'EOF'
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Session;

class LanguageController extends Controller
{
    /**
     * 切换语言
     */
    public function switch(Request $request): RedirectResponse
    {
        $locale = $request->input('locale');
        $availableLocales = array_keys(config('app.available_locales'));
        
        // 验证语言代码是否有效
        if (!in_array($locale, $availableLocales)) {
            return back()->with('error', 'Invalid language selected.');
        }
        
        // 保存语言偏好到session
        Session::put('locale', $locale);
        
        // 获取当前路径并替换语言前缀
        $currentPath = $request->input('current_path', '/');
        $pathSegments = explode('/', trim($currentPath, '/'));
        
        // 如果第一个段是语言代码，替换它
        if (count($pathSegments) > 0 && in_array($pathSegments[0], $availableLocales)) {
            $pathSegments[0] = $locale;
        } else {
            // 如果没有语言前缀，添加一个
            array_unshift($pathSegments, $locale);
        }
        
        $newPath = '/' . implode('/', $pathSegments);
        
        return redirect($newPath)->with('success', 'Language changed successfully.');
    }
}
EOF

log_success "控制器创建完成"

# 第三步：创建服务类
log_info "创建服务类..."

# 创建服务目录
mkdir -p app/Services

# LoanCalculatorService
cat > app/Services/LoanCalculatorService.php << 'EOF'
<?php

namespace App\Services;

class LoanCalculatorService
{
    /**
     * 计算等额本息还款
     */
    public function calculateEqualPayment(float $principal, float $annualRate, int $months): array
    {
        $monthlyRate = $annualRate / 100 / 12;
        
        if ($monthlyRate == 0) {
            $monthlyPayment = $principal / $months;
            $totalPayment = $principal;
            $totalInterest = 0;
        } else {
            $monthlyPayment = $principal * ($monthlyRate * pow(1 + $monthlyRate, $months)) / 
                             (pow(1 + $monthlyRate, $months) - 1);
            $totalPayment = $monthlyPayment * $months;
            $totalInterest = $totalPayment - $principal;
        }
        
        return [
            'monthly_payment' => round($monthlyPayment, 2),
            'total_payment' => round($totalPayment, 2),
            'total_interest' => round($totalInterest, 2),
            'schedule' => $this->generateAmortizationSchedule($principal, $annualRate, $months, 'equal_payment')
        ];
    }
    
    /**
     * 生成还款计划表
     */
    public function generateAmortizationSchedule(float $principal, float $annualRate, int $months, string $type = 'equal_payment'): array
    {
        $monthlyRate = $annualRate / 100 / 12;
        $monthlyPayment = $this->calculateEqualPayment($principal, $annualRate, $months)['monthly_payment'];
        $schedule = [];
        $remainingBalance = $principal;
        
        for ($month = 1; $month <= $months; $month++) {
            $interestPayment = $remainingBalance * $monthlyRate;
            $principalPayment = $monthlyPayment - $interestPayment;
            $remainingBalance -= $principalPayment;
            
            $schedule[] = [
                'month' => $month,
                'monthly_payment' => round($monthlyPayment, 2),
                'principal_payment' => round($principalPayment, 2),
                'interest_payment' => round($interestPayment, 2),
                'remaining_balance' => round(max(0, $remainingBalance), 2)
            ];
        }
        
        return $schedule;
    }
}
EOF

log_success "服务类创建完成"

echo ""
log_success "🎉 FastPanel应用文件创建完成！"
echo ""
log_info "接下来需要："
echo "1. 创建视图文件"
echo "2. 创建多语言文件"
echo "3. 配置路由"
echo "4. 设置文件权限"
echo ""
log_info "请运行 fastpanel-create-views.sh 来完成视图文件创建..."
