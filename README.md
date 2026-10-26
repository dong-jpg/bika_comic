# HaKa Comic

[![License: GPL-3.0](https://img.shields.io/badge/License-GPL%203.0-blue.svg?logo=gnu)](https://opensource.org/licenses/GPL-3.0)
![Upstream](https://img.shields.io/badge/upstream-raoxwup%2Fhaka__comic-24292f?logo=github)

> 本仓库是 [raoxwup/haka_comic](https://github.com/raoxwup/haka_comic) 的个人 fork，在其基础上做了首页改版等功能调整，并通过 GitHub Actions 自建发行版。感谢上游项目的优秀工作 👏

## 📖 项目简介

第三方哔咔漫画跨平台客户端（学习 Flutter 的练习项目），支持 Android、iOS、macOS、Windows、Linux 平台。

## ✨ 与上游的主要差异

- **首页改版**：分类大方块改为「分类 Tab + 封面网格」布局，直观浏览漫画封面，左右滑动或点按 Tab 切换分类，「最新」固定首位，各分类独立保活（滚动位置/排序不丢失）
- **分类管理**：设置 → 分类管理，支持**拖动排序**与**显隐开关**，顺序同时作用于首页 Tab 与分类页
- **自建 CI 发行版**：工作流内置固定签名密钥，fork 无需配置任何 secrets 即可构建，产物签名一致、可直接覆盖升级

---

## 🖼️ 项目截图

| 分类浏览                                          | 漫画列表                                              | 漫画详情                                              | 阅读界面                                          |
| ------------------------------------------------- | ----------------------------------------------------- | ----------------------------------------------------- | ------------------------------------------------- |
| <img src="./screenshots/分类.png" width="200">    | <img src="./screenshots/漫画列表.png" width="200">    | <img src="./screenshots/漫画详情.png" width="200">    | <img src="./screenshots/阅读.png" width="200">    |
| <img src="./screenshots/pc-分类.png" width="200"> | <img src="./screenshots/pc-漫画列表.png" width="200"> | <img src="./screenshots/pc-漫画详情.png" width="200"> | <img src="./screenshots/pc-阅读.png" width="200"> |

**截图已经过时（首页已改版），以实际项目界面为主**

---

## ⬇️ 下载

本 fork 的所有平台安装包都在 GitHub [Releases](https://github.com/dong-jpg/bika_comic/releases)（由 Actions 构建并发布）。

| 平台    | 资源类型                                        | 选择建议 / 备注                                                                                                                                                                                                                                                               |
| ------- | ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Android | `APK`（`arm64` 推荐 / `universal` 通用 / 可选） | 大多数真机选 `arm64`；不确定就选 `universal`（体积更大）。`x86_64` 通常用于模拟器。                                                                                                                                                                                           |
| iOS     | `IPA`（未签名）                                 | 需要自签/侧载后才能安装。推荐用 SideStore/AltStore：添加源 `alt_store.json`（`https://raw.githubusercontent.com/dong-jpg/bika_comic/main/alt_store.json`），并按官方文档完成前置配置（如 [SideStore 安装前置](https://docs.sidestore.io/zh/docs/installation/prerequisites)）。 |
| macOS   | `DMG`                                           | 首次打开可能需要在系统安全设置里手动允许。                                                                                                                                                                                                                                    |
| Windows | `EXE`                                           | Inno Setup 安装器，可能触发 SmartScreen 提示，按需放行。                                                                                                                                                                                                                      |
| Linux   | `DEB`（`amd64` / `arm64`）                      | Debian/Ubuntu 系：`sudo apt install ./xxx.deb`。目前仅提供 `.deb`。                                                                                                                                                                                                           |

> ⚠️ 本 fork 构建的应用使用**自有签名**，与上游官方版签名不同：两者无法互相覆盖安装，切换前请先在应用内通过 WebDAV 备份数据。

> 提示：具体资产文件名会随版本变化，按 Release 页面展示为准。

---

## 🛠️ 开发环境

| 组件           | 版本要求                                             | 官网安装指南                                                       | 验证命令                                  |
| -------------- | ---------------------------------------------------- | ------------------------------------------------------------------ | ----------------------------------------- |
| Flutter SDK    | `3.44.8`（见 `pubspec.yaml`）                        | [Flutter 安装文档](https://docs.flutter.dev/get-started/install)   | `flutter --version` / `flutter doctor -v` |
| Dart SDK       | `>= 3.12.0 < 4.0.0`（见 `pubspec.yaml`）             | [Dart SDK 安装文档](https://dart.dev/get-dart)                     | `dart --version`                          |
| Rust toolchain | 建议使用 stable（本项目 Rust crate 为 edition 2021） | [Rust 安装文档（rustup）](https://www.rust-lang.org/tools/install) | `rustc --version` / `cargo --version`     |

> 说明：Flutter SDK 自带 Dart SDK；如果你已经安装了 Flutter，一般无需再单独安装 Dart。国内网络建议配置镜像环境变量 `PUB_HOSTED_URL=https://pub.flutter-io.cn` 与 `FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn`。

### 测试

```bash
flutter test          # 全量测试
flutter analyze       # 静态检查
```

---

## ⚠️ 免责声明

1. 本项目为**非官方第三方应用**，与哔咔漫画官方无任何关联
2. 仅用于**技术交流与学习**目的，禁止用于商业用途
3. 使用本软件产生的一切后果由使用者自行承担
4. 资源内容版权归原作者及平台所有，请于下载后 24 小时内删除

---

## 🙏 致谢

- [raoxwup/haka_comic](https://github.com/raoxwup/haka_comic) —— 本项目的上游，所有基础功能均来自此项目
- [Mihon](https://github.com/mihonapp/mihon) —— 首页改版的交互参考
