# Flutter 示例仓库 (Flutter Example)

这是一个用于存放和演示 Flutter 示例代码及相关实践的仓库，采用 MVVM 架构，集成了 Supabase、Riverpod 状态管理等现代化开发方案。

## 环境要求

### Flutter SDK
- **版本要求**：`>= 3.2.0 < 4.0.0`
- **推荐版本**：Flutter 3.24+ / Dart 3.5+

检查你的 Flutter 版本：
```bash
flutter --version
```

如需升级 Flutter：
```bash
flutter upgrade
```

### 环境变量配置

本项目使用 Supabase 作为后端服务，需要配置环境变量。

#### 1. 复制环境变量模板

```bash
cp .env.example .env
```

#### 2. 配置 Supabase 凭证

编辑 `.env` 文件，填入你的 Supabase 项目信息：

```env
# Supabase 配置
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

**获取 Supabase 凭证：**
1. 访问 [Supabase Dashboard](https://app.supabase.com/)
2. 选择你的项目
3. 进入 `Settings` → `API`
4. 复制 `Project URL` 和 `anon/public` key

> ⚠️ **注意**：`.env` 文件包含敏感信息，已添加到 `.gitignore`，请勿提交到版本控制系统。

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/your-username/flutter-example.git
cd flutter-example
```

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 生成代码（可选）

如果修改了 Riverpod、Freezed 或 JSON 序列化相关代码，需要运行：

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. 运行项目

```bash
flutter run
```

## 项目特性

- ✅ **MVVM 架构**：清晰的代码组织和职责分离
- ✅ **Supabase 集成**：后端即服务（BaaS）解决方案
- ✅ **Riverpod 状态管理**：类型安全的响应式状态管理
- ✅ **Go Router 路由**：声明式路由和深度链接支持
- ✅ **国际化支持**：多语言切换（中文/英文）
- ✅ **主题切换**：浅色/深色/跟随系统
- ✅ **代码生成**：Freezed、JSON 序列化、路由生成
- ✅ **丰富示例**：包含 40+ 个实用 Demo

## 核心依赖

| 依赖 | 版本 | 用途 |
|------|------|------|
| `supabase_flutter` | ^2.8.3 | Supabase 客户端 |
| `flutter_riverpod` | ^2.6.1 | 状态管理 |
| `go_router` | ^14.6.0 | 路由管理 |
| `flutter_dotenv` | ^5.1.0 | 环境变量管理 |
| `dio` | ^5.7.0 | HTTP 客户端 |
| `flutter_slidable` | ^3.1.1 | 列表侧滑操作 |

完整依赖列表请查看 [`pubspec.yaml`](./pubspec.yaml)。

## 项目结构

```
lib/
├── core/           # 核心功能（存储、结果类型等）
├── data/           # 数据层（模型、数据源）
├── models/         # 数据模型
├── net/            # 网络层（API 服务、HTTP 客户端）
├── pages/          # 页面（UI 层）
├── providers/      # Riverpod Providers
├── repositories/   # 仓库层（数据访问抽象）
├── routers/        # 路由配置
├── services/       # 服务层（通知、存储等）
├── utils/          # 工具类
├── view_models/    # 视图模型（业务逻辑）
├── widgets/        # 通用组件
└── main.dart       # 应用入口
```

## 学习资源

如果你是首次接触 Flutter 开发，以下官方资源可以帮助你快速入门：

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [在线文档](https://docs.flutter.dev/)：详细的教程、示例、跨平台开发指南以及完整的 API 参考

## 常见问题

### Q: 运行时提示 "Missing .env file"

**A:** 请确保已复制 `.env.example` 为 `.env` 并填入正确的 Supabase 凭证。

### Q: 代码生成失败

**A:** 尝试清理缓存后重新生成：
```bash
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Q: iOS 构建失败

**A:** 确保已安装 CocoaPods 并更新 pods：
```bash
cd ios
pod install
cd ..
```

## 贡献指南

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

---

**Happy Coding!** 🚀
