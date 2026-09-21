# Changelog

本文件记录 unilist 的版本变更。格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [1.0.0] - 2026-09-21

首个版本。

### 组件

- `UniList` —— 通用列表。内置下拉刷新、触底自动加载、底部状态栏（加载中 / 没有更多 / 加载失败可重试）、空态 / 错误态 / 骨架屏。
- `UniGrid` —— 网格，`columns` 支持运行时变更。
- `UniWaterfall` —— 瀑布流，卡片高度由 `itemHeight` 回调决定。
- `UniGroupList` —— 分组列表，支持吸顶、折叠、右侧字母索引条。
- `UniSwipeItem` —— 侧滑菜单项，支持多按钮与自定义宽度，可独立使用或由 `UniList` 托管。

### 数据与状态

- 两个数据入口：`items`（`ForEach`，适合数百条以内）与 `dataSource`（`LazyForEach`，支持增量通知，适合大数据量）。
- `UniState.Auto` 由数据量与加载状态自动推导，调用方无需手动维护状态枚举。
- `hasMore` 直接控制底部状态，置 `false` 时自动显示「没有更多了」。

### 主题

- `UniTheme` 覆盖颜色、圆角、间距、字号等视觉参数。
- 内置 `resources/dark` 资源，深色模式开箱可用，调用方无需额外适配。
- `UniTexts` 集中管理全部可见文案，便于替换或国际化。

### 列表能力

- 下拉刷新与触底加载：内置互斥与防抖，避免 `onReachEnd` 在 Spring 边缘效果下重复触发。
- 拖拽排序（`enableDrag`）、侧滑菜单（`enableSwipe`）、回到顶部悬浮按钮。
- 头部区（`headerBuilder`）与吸顶区（`stickyHeaderBuilder`）。
- 分组渲染（`groups` / `groupOf` / `sectionHeaderBuilder`）。

### 兼容性

- 基线 `compatibleSdkVersion 6.0.0(20)`，未使用任何 `@since > 20` 的能力。

[1.0.0]: https://github.com/linwenlong-monkey/unilist/releases/tag/1.0.0
