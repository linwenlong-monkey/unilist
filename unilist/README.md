# unilist

HarmonyOS（ArkTS）列表组件库。**组件接管滚动容器**——调用方只提供数据和「一行长什么样」，
下拉刷新、触底加载、底部状态、空态 / 错误态 / 骨架屏、卡片视觉全部由组件完成。

基线：`compatibleSdkVersion 6.0.0(20)`。凡标注 `@since > 20` 的能力一律未使用。

## 安装

```json5
// entry/oh-package.json5
{ "dependencies": { "unilist": "file:../unilist" } }
```

## 快速开始

```ts
import { UniList, UniState, UniTheme, UniTexts } from 'unilist';

@Entry
@Component
struct Demo {
  @State items: Goods[] = [];
  @State hasMore: boolean = true;

  @Builder
  row(item: Object, index: number): void {
    Text((item as Goods).name).fontSize(16)
  }

  build() {
    UniList({
      items: this.items,
      hasMore: this.hasMore,
      onRefresh: () => this.reload(),      // () => Promise<void>
      onLoadMore: () => this.loadNext(),   // () => Promise<void> | void
      itemBuilder: (item: Object, index: number) => {
        this.row(item, index)              // 箭头函数包裹 + 走 @Builder 方法
      }
    })
  }
}
```

页面里**不再出现** `List` / `Refresh` / `ForEach` / `ListItem`。

## 两条必须遵守的写法

这两条都是运行期才会炸、编译期完全不报错的坑，踩过一次就够了。

### 1. `itemBuilder` 必须用箭头函数包裹，不能传裸引用

```ts
// 正确：箭头函数词法捕获父组件的 this
UniList({ items: this.items, itemBuilder: (item, i) => { this.row(item, i) } })

// 错误：传裸引用时，组件内调用它的 this 会绑到子组件上
UniList({ items: this.items, itemBuilder: this.row })
```

同样的规则适用于所有把 `@Builder` 当值传出去的地方，例如 `WaterFlow` 的 `footer`、
`ListItemGroup` 的 `header` / `footer`。

### 2. `itemBuilder` 体内不要直接实例化自定义组件，要经由 `@Builder` 方法

```ts
// ✅ 正确
@Builder
row(item: Object, index: number): void {
  MyRow({ data: item as Goods })     // 或者调用全局 @Builder
}

// ❌ 错误：运行期抛 "Cannot read property observeComponentCreation2 of undefined"
itemBuilder: (item, i) => {
  MyRow({ data: item as Goods })
}
```

原因：传出去的箭头函数体不是组件的构建作用域，拿不到渲染上下文。

同理，**`@Prop` 不要用于带参构造函数的类实例**——`@Prop` 会深拷贝，而拷贝时无法重新
`new` 出该实例，运行期抛 `class constructor cannot called without 'new'`。
数据对象用普通成员，或者把字段拆成基础类型。

## 组件

| 组件 | 用途 |
|---|---|
| `UniList` | 通用列表。刷新 / 触底 / 拖拽 / 侧滑 / 悬浮回顶 |
| `UniGrid` | 网格，`columns` 运行时可变 |
| `UniWaterfall` | 瀑布流，卡片高度由 `itemHeight` 回调决定 |
| `UniGroupList` | 分组，支持吸顶 / 折叠 / 索引条 |
| `UniSwipeItem` | 侧滑项，可独立使用，也可由 `UniList` 托管 |

### 数据入口

- `items: Object[]` —— 普通数组，内部走 `ForEach`，适合几百条以内。
- `dataSource?: IDataSource` —— 走 `LazyForEach`，适合大数据量，且支持增量通知
  （`onDataAdd` 等）而不触发全量重建。**优先级高于 `items`**。

ArkTS 的 `@Component struct` 不支持泛型，所以 `items` 元素类型是 `Object`，
调用方在 builder 里 `as` 回具体类型。

### 状态

默认 `state: UniState.Auto`，由 `items.length` / `loading` / `errorMessage` 自动推导，
调用方**不需要**手动维护状态枚举。只有需要强制展示某个状态时才显式传 `state`。

`hasMore` 单独控制底部：置 `false` 时底部自动变成「没有更多了」。

### 主题与深色模式

`UniTheme` 的颜色字段默认指向组件库自带的 `$r` 资源，因此**天然支持深色模式**，
调用方不需要为暗色做任何事。定制时构造一个 `UniTheme` 实例、覆盖需要的字段再传入即可：

```ts
const myTheme = new UniTheme();
myTheme.primary = '#FF6B00';
myTheme.cardRadius = 16;

UniList({ theme: myTheme, ... })
```

组件库的颜色资源全部以 `uni_` 为前缀。**宿主 App 不要定义同名 `app.color.uni_*`**——
HAR 资源与宿主合并时优先级为 `AppScope > 宿主 HAP > HAR`，同名会被静默覆盖，
连暗色适配一起失效。

## 已知限制（API 20 基线）

- **「一次只滑开一个」无法完美实现。** 关闭指定 item 的侧滑需要
  `ListItemSwipeActionManager`（`@since 21`），而 `ListScroller.closeAllSwipeActions()`
  会把当前正在操作的那个也一起收起。目前只保证「点按钮后立即收起自己」。
  另外**不要**用 `onScrollStart` + `closeAllSwipeActions` 做「滚动时收起」——
  该回调会被侧滑手势本身触发，导致菜单刚滑开就被自己关掉。
- **拖拽排序与 `dataSource` 互斥。** 拖拽依赖 `ForEach.onMove`，该回调只在父容器是
  `List` 且直接用 `ForEach` 时生效，`LazyForEach` 不支持。拖拽与 `enableSwipe` 也互斥。
- **`ForEach` 的 key 默认用下标**，启用拖拽时**必须**传 `itemKey`，否则拖拽后
  item 与数据的对应关系会错乱。

## 目录结构

```
components/
├── UniList.ets / UniGrid.ets / UniWaterfall.ets / UniGroupList.ets / UniSwipeItem.ets
├── internal/    共享实现，不对外导出
│   ├── UniStateView.ets   三态（骨架屏 / 空 / 错误）默认渲染
│   ├── UniSkeleton.ets    骨架屏
│   ├── UniFooter.ets      底部状态栏
│   ├── UniLoadGuard.ets   触底去重闸门
│   └── UniFloatingTop.ets 回到顶部
├── theme/       UniTheme / UniRes / UniTexts
└── common/      UniTypes
```
