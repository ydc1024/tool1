#!/bin/bash

# PHP Calculator Platform FastPanel 视图文件创建脚本
# 第三部分：创建视图和多语言文件

set -e

echo "🎨 开始创建FastPanel视图文件..."

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

# 第一步：创建布局文件
log_info "创建布局文件..."

mkdir -p resources/views/layouts
mkdir -p resources/views/components

cat > resources/views/layouts/app.blade.php << 'EOF'
<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}" dir="{{ app()->getLocale() === 'ar' ? 'rtl' : 'ltr' }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    
    <title>@yield('title', __('common.site_title'))</title>
    <meta name="description" content="@yield('description', __('common.site_description'))">
    
    <!-- SEO多语言标签 -->
    @foreach(config('app.available_locales') as $localeCode => $localeName)
        <link rel="alternate" hreflang="{{ $localeCode }}" href="{{ url('/' . $localeCode . request()->getPathInfo()) }}">
    @endforeach
    <link rel="alternate" hreflang="x-default" href="{{ url('/en' . request()->getPathInfo()) }}">
    
    <!-- Favicon -->
    <link rel="icon" type="image/x-icon" href="/favicon.ico">
    
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=inter:300,400,500,600,700&display=swap" rel="stylesheet" />
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['Inter', 'sans-serif'],
                    },
                    colors: {
                        primary: {
                            50: '#eff6ff',
                            500: '#3b82f6',
                            600: '#2563eb',
                            700: '#1d4ed8',
                        }
                    }
                }
            }
        }
    </script>
    
    <!-- Alpine.js -->
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
    
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    
    @stack('styles')
</head>
<body class="bg-gray-50 font-sans antialiased">
    <div id="app">
        <!-- 导航栏 -->
        <nav class="bg-white shadow-sm border-b border-gray-200">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div class="flex justify-between h-16">
                    <!-- Logo和主导航 -->
                    <div class="flex">
                        <div class="flex-shrink-0 flex items-center">
                            <a href="{{ route('home', ['locale' => app()->getLocale()]) }}" class="text-xl font-bold text-gray-900">
                                {{ __('common.site_title') }}
                            </a>
                        </div>
                        
                        <!-- 主导航菜单 -->
                        <div class="hidden sm:ml-6 sm:flex sm:space-x-8">
                            <a href="#" class="border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium">
                                {{ __('common.nav.loan_calculator') }}
                            </a>
                            <a href="#" class="border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium">
                                {{ __('common.nav.bmi_calculator') }}
                            </a>
                            <a href="#" class="border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium">
                                {{ __('common.nav.currency_converter') }}
                            </a>
                        </div>
                    </div>
                    
                    <!-- 语言选择器 -->
                    <div class="flex items-center">
                        @include('components.language-selector')
                    </div>
                </div>
            </div>
        </nav>
        
        <!-- 主内容区域 -->
        <main class="min-h-screen">
            @yield('content')
        </main>
        
        <!-- 页脚 -->
        <footer class="bg-white border-t border-gray-200">
            <div class="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
                <div class="text-center">
                    <p class="text-gray-600">{{ __('common.footer.copyright') }}</p>
                </div>
            </div>
        </footer>
    </div>
    
    @stack('scripts')
</body>
</html>
EOF

log_success "布局文件创建完成"

# 第二步：创建语言选择器组件
log_info "创建语言选择器组件..."

cat > resources/views/components/language-selector.blade.php << 'EOF'
<div x-data="languageSelector()" class="relative">
    <!-- 当前语言按钮 -->
    <button @click="toggle()" 
            class="flex items-center space-x-2 px-3 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500">
        <span x-text="currentLanguage.name"></span>
        <svg class="w-4 h-4 transition-transform duration-200" 
             :class="{ 'rotate-180': open }" 
             fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
        </svg>
    </button>
    
    <!-- 语言选项下拉菜单 -->
    <div x-show="open" 
         x-transition:enter="transition ease-out duration-100"
         x-transition:enter-start="transform opacity-0 scale-95"
         x-transition:enter-end="transform opacity-100 scale-100"
         x-transition:leave="transition ease-in duration-75"
         x-transition:leave-start="transform opacity-100 scale-100"
         x-transition:leave-end="transform opacity-0 scale-95"
         @click.away="close()"
         class="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg border border-gray-200 z-50">
        
        <div class="py-1">
            <template x-for="(language, code) in languages" :key="code">
                <form method="POST" action="{{ route('language.switch') }}">
                    @csrf
                    <input type="hidden" name="locale" :value="code">
                    <input type="hidden" name="current_path" value="{{ request()->getRequestUri() }}">
                    <button type="submit" 
                            class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 flex items-center space-x-3"
                            :class="{ 'bg-gray-100 font-medium': code === currentLocale }">
                        <span class="text-lg" x-text="language.flag"></span>
                        <span x-text="language.name"></span>
                        <svg x-show="code === currentLocale" class="w-4 h-4 text-primary-600 ml-auto" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                        </svg>
                    </button>
                </form>
            </template>
        </div>
    </div>
</div>

<script>
function languageSelector() {
    return {
        open: false,
        currentLocale: '{{ app()->getLocale() }}',
        languages: {
            'en': { name: 'English', flag: '🇺🇸' },
            'es': { name: 'Español', flag: '🇪🇸' },
            'fr': { name: 'Français', flag: '🇫🇷' },
            'de': { name: 'Deutsch', flag: '🇩🇪' }
        },
        
        get currentLanguage() {
            return this.languages[this.currentLocale] || this.languages['en'];
        },
        
        toggle() {
            this.open = !this.open;
        },
        
        close() {
            this.open = false;
        }
    }
}
</script>
EOF

log_success "语言选择器组件创建完成"

# 第三步：创建首页视图
log_info "创建首页视图..."

cat > resources/views/home.blade.php << 'EOF'
@extends('layouts.app')

@section('title', __('common.site_title'))
@section('description', __('common.site_description'))

@section('content')
<!-- Hero Section -->
<div class="bg-gradient-to-r from-primary-600 to-primary-700">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
        <div class="text-center">
            <h1 class="text-4xl md:text-6xl font-bold text-white mb-6">
                {{ __('common.site_title') }}
            </h1>
            <p class="text-xl text-primary-100 mb-8 max-w-3xl mx-auto">
                {{ __('common.site_description') }}
            </p>
            <div class="flex flex-wrap justify-center gap-4">
                @foreach($calculators as $calculator)
                    <a href="#" 
                       class="bg-white text-primary-600 px-6 py-3 rounded-lg font-semibold hover:bg-primary-50 transition-colors duration-200">
                        {{ $calculator['name'] }}
                    </a>
                @endforeach
            </div>
        </div>
    </div>
</div>

<!-- 统计数据 -->
<div class="bg-white py-16">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="grid grid-cols-2 md:grid-cols-4 gap-8">
            <div class="text-center">
                <div class="text-3xl font-bold text-gray-900">{{ number_format($stats['total_calculations']) }}+</div>
                <div class="text-gray-600 mt-2">Total Calculations</div>
            </div>
            <div class="text-center">
                <div class="text-3xl font-bold text-gray-900">{{ number_format($stats['active_users']) }}+</div>
                <div class="text-gray-600 mt-2">Active Users</div>
            </div>
            <div class="text-center">
                <div class="text-3xl font-bold text-gray-900">{{ $stats['supported_currencies'] }}+</div>
                <div class="text-gray-600 mt-2">Currencies</div>
            </div>
            <div class="text-center">
                <div class="text-3xl font-bold text-gray-900">{{ $stats['languages_supported'] }}</div>
                <div class="text-gray-600 mt-2">Languages</div>
            </div>
        </div>
    </div>
</div>

<!-- 计算器功能展示 -->
<div class="bg-gray-50 py-16">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-12">
            <h2 class="text-3xl font-bold text-gray-900 mb-4">Professional Calculators</h2>
            <p class="text-lg text-gray-600 max-w-2xl mx-auto">
                Choose from our suite of professional-grade calculators designed for accuracy and ease of use.
            </p>
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
            @foreach($calculators as $calculator)
                <div class="bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow duration-200 overflow-hidden">
                    <div class="p-6">
                        <div class="flex items-center mb-4">
                            <div class="w-12 h-12 bg-{{ $calculator['color'] }}-100 rounded-lg flex items-center justify-center mr-4">
                                <!-- Icon placeholder -->
                                <svg class="w-6 h-6 text-{{ $calculator['color'] }}-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path>
                                </svg>
                            </div>
                            <h3 class="text-xl font-semibold text-gray-900">{{ $calculator['name'] }}</h3>
                        </div>
                        
                        <p class="text-gray-600 mb-6">{{ $calculator['description'] }}</p>
                        
                        <ul class="space-y-2 mb-6">
                            @foreach($calculator['features'] as $feature)
                                <li class="flex items-center text-sm text-gray-600">
                                    <svg class="w-4 h-4 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                                    </svg>
                                    {{ $feature }}
                                </li>
                            @endforeach
                        </ul>
                        
                        <a href="#" 
                           class="block w-full text-center bg-{{ $calculator['color'] }}-600 text-white py-2 px-4 rounded-lg hover:bg-{{ $calculator['color'] }}-700 transition-colors duration-200">
                            {{ __('common.buttons.calculate') }}
                        </a>
                    </div>
                </div>
            @endforeach
        </div>
    </div>
</div>
@endsection
EOF

log_success "首页视图创建完成"

echo ""
log_success "🎉 FastPanel视图文件创建完成！"
echo ""
log_info "接下来需要："
echo "1. 创建多语言文件"
echo "2. 配置路由"
echo "3. 设置文件权限"
echo "4. 完成部署配置"
echo ""
log_info "请运行 fastpanel-finalize.sh 来完成最终配置..."
