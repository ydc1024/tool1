#!/bin/bash

# PHP Calculator Platform 视图文件创建脚本
# 第三部分：创建所有视图文件

set -e

echo "🎨 开始创建视图文件..."

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

# 第一步：创建主布局文件
log_info "创建主布局文件..."

cat > resources/views/layouts/app.blade.php << 'EOF'
<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}" dir="{{ app()->getLocale() === 'ar' ? 'rtl' : 'ltr' }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    
    <title>@yield('title', 'PHP Calculator Platform')</title>
    <meta name="description" content="@yield('description', 'Professional financial and health calculators')">
    
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
</head>
<body class="bg-gray-50 font-sans antialiased">
    <div id="app">
        <!-- 导航栏 -->
        <nav class="bg-white shadow-sm border-b border-gray-200">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div class="flex justify-between h-16">
                    <!-- Logo -->
                    <div class="flex items-center">
                        <a href="{{ route('home', ['locale' => app()->getLocale()]) }}" class="text-xl font-bold text-gray-900">
                            PHP Calculator Platform
                        </a>
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
                    <p class="text-gray-600">© 2024 PHP Calculator Platform. All rights reserved.</p>
                    <p class="text-sm text-gray-500 mt-2">Current Language: {{ strtoupper(app()->getLocale()) }}</p>
                </div>
            </div>
        </footer>
    </div>
</body>
</html>
EOF

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
                <a :href="'/' + code + '/'" 
                   class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 flex items-center space-x-3 block"
                   :class="{ 'bg-gray-100 font-medium': code === currentLocale }">
                    <span class="text-lg" x-text="language.flag"></span>
                    <span x-text="language.name"></span>
                    <svg x-show="code === currentLocale" class="w-4 h-4 text-primary-600 ml-auto" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                    </svg>
                </a>
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

# 第三步：创建首页视图
log_info "创建首页视图..."

cat > resources/views/home.blade.php << 'EOF'
@extends('layouts.app')

@section('title', 'PHP Calculator Platform')
@section('description', 'Professional financial and health calculators for loan, BMI, and currency conversion')

@section('content')
<!-- Hero Section -->
<div class="bg-gradient-to-r from-primary-600 to-primary-700">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
        <div class="text-center">
            <h1 class="text-4xl md:text-6xl font-bold text-white mb-6">
                PHP Calculator Platform
            </h1>
            <p class="text-xl text-primary-100 mb-8 max-w-3xl mx-auto">
                Professional financial and health calculators for loan, BMI, and currency conversion
            </p>
            <div class="text-lg text-primary-200 mb-8">
                Current Language: <span class="font-semibold">{{ strtoupper($locale) }}</span>
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
                                <svg class="w-6 h-6 text-{{ $calculator['color'] }}-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path>
                                </svg>
                            </div>
                            <h3 class="text-xl font-semibold text-gray-900">{{ $calculator['name'] }}</h3>
                        </div>
                        
                        <p class="text-gray-600 mb-6">{{ $calculator['description'] }}</p>
                        
                        <button class="block w-full text-center bg-{{ $calculator['color'] }}-600 text-white py-2 px-4 rounded-lg hover:bg-{{ $calculator['color'] }}-700 transition-colors duration-200">
                            Coming Soon
                        </button>
                    </div>
                </div>
            @endforeach
        </div>
    </div>
</div>

<!-- 多语言测试区域 -->
<div class="bg-white py-16">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center">
            <h2 class="text-3xl font-bold text-gray-900 mb-8">Multi-Language Support Test</h2>
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                <a href="/en/" class="block p-4 border-2 border-blue-200 rounded-lg hover:border-blue-400 transition-colors">
                    <div class="text-2xl mb-2">🇺🇸</div>
                    <div class="font-semibold">English</div>
                    <div class="text-sm text-gray-600">Default</div>
                </a>
                <a href="/es/" class="block p-4 border-2 border-red-200 rounded-lg hover:border-red-400 transition-colors">
                    <div class="text-2xl mb-2">🇪🇸</div>
                    <div class="font-semibold">Español</div>
                    <div class="text-sm text-gray-600">Spanish</div>
                </a>
                <a href="/fr/" class="block p-4 border-2 border-blue-200 rounded-lg hover:border-blue-400 transition-colors">
                    <div class="text-2xl mb-2">🇫🇷</div>
                    <div class="font-semibold">Français</div>
                    <div class="text-sm text-gray-600">French</div>
                </a>
                <a href="/de/" class="block p-4 border-2 border-yellow-200 rounded-lg hover:border-yellow-400 transition-colors">
                    <div class="text-2xl mb-2">🇩🇪</div>
                    <div class="font-semibold">Deutsch</div>
                    <div class="text-sm text-gray-600">German</div>
                </a>
            </div>
        </div>
    </div>
</div>
@endsection
EOF

log_success "视图文件创建完成！"
echo ""
log_info "接下来运行最后一个脚本来完成部署..."
