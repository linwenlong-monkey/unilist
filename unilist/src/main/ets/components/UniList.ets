import { UniItemKey, UniLoadState, UniSkeletonVariant, UniState, UniSwipeAction } from './common/UniTypes';
import { UniSwipeItem } from './UniSwipeItem';
import { UniTheme } from './theme/UniTheme';
import { UniTexts } from './theme/UniTexts';
import { UniStateView } from './internal/UniStateView';
import { UniFooter } from './internal/UniFooter';
import { UniFloatingTop } from './internal/UniFloatingTop';
import { UniLoadGuard } from './internal/UniLoadGuard';

/**
 * 通用列表。
 *
 * 组件**接管了滚动容器**：内部的 `Refresh` / `List` / `ForEach` 全部封装在库内，
 * 调用方只需要给数据和「一行长什么样」。下拉刷新、触底自动加载、底部状态、
 * 空态 / 错误态 / 骨架屏、卡片视觉都由组件自己完成。
 *
 * 两个数据入口，二选一：
 * - {@link items} 普通数组，内部用 `ForEach`，适合几百条以内。
 * - {@link dataSource} `IDataSource`，内部用 `LazyForEach`，适合大数据量，
 *   并且支持增量通知（`notifyDataAdd` 等）而不触发全量重建。
 *
 * ⚠️ `itemBuilder` **必须用箭头函数包裹**：
 * ```ts
 * // 正确 —— 箭头函数词法捕获父组件的 this
 * UniList({ items: this.items, itemBuilder: (item, i) => { this.row(item, i) } })
 * // 错误 —— 传裸引用时组件内的 this 会绑到子组件上，编译期不报错但运行期取不到数据
 * UniList({ items: this.items, itemBuilder: this.row })
 * ```
 */
@Component
export struct UniList {
  // ---------- 数据 ----------
  /** 列表数据。走 `ForEach` 路径。 */
  @Prop items: Object[] = [];
  /**
   * 大数据量数据源。走 `LazyForEach` 路径，优先级高于 `items`。
   *
   * 刻意**不加** `@Prop`：`LazyForEach` 自己会 `registerDataChangeListener` 订阅数据源，
   * 增量更新完全绕开 ArkTS 的状态装饰器；加了 `@Prop` 反而会深拷贝一份
   * `IDataSource`，把监听器一起拷坏。
   */
  dataSource?: IDataSource;
  /**
   * 取稳定唯一 key 的函数。
   *
   * 默认用下标，**启用拖拽时必须提供**——下标做 key 时拖拽后 item 与数据的对应关系会错乱。
   */
  itemKey?: UniItemKey;

  // ---------- 状态 ----------
  /**
   * 内容状态。默认 {@link UniState.Auto}，由 `items.length` / `loading` / `errorMessage`
   * 自动推导；只有需要强制展示某个状态（比如示例的状态画廊）时才显式指定。
   */
  @Prop state: UniState = UniState.Auto;
  /** 是否还有下一页。为 false 时底部显示「没有更多了」。 */
  @Prop hasMore: boolean = false;
  /** 首屏加载中标记，仅在 `state` 为 Auto 且无数据时参与推导。 */
  @Prop loading: boolean = false;
  /** 错误信息，非空即视为错误态（`state` 为 Auto 时参与推导）。 */
  @Prop errorMessage: string = '';

  // ---------- 外观 ----------
  @Prop theme: UniTheme = UniTheme.standard;
  @Prop texts: UniTexts = UniTexts.standard;
  /** 是否给每行套卡片样式（圆角 + 底色 + 阴影）。关掉即退化成朴素分隔线列表。 */
  @Prop card: boolean = true;

  // ---------- 能力开关 ----------
  @Prop enableRefresh: boolean = true;
  @Prop enableLoadMore: boolean = true;
  /**
   * 启用拖拽排序。
   *
   * 依赖 `ForEach.onMove`，而该回调**只在父容器是 `List` 且直接用 `ForEach` 时生效**，
   * 因此：与 `dataSource`（`LazyForEach` 路径）互斥，本组件在此场景下会静默忽略。
   */
  @Prop enableDrag: boolean = false;
  @Prop enableFloatingTop: boolean = true;
  /**
   * 给每一行启用侧滑菜单。
   *
   * 开启后行会由 {@link UniSwipeItem} 包装，调用方**不需要**再手写 `ListItem`。
   * 与 {@link enableDrag} 互斥——拖拽要求 `ForEach` 直接产出 `ListItem`，
   * 侧滑会在中间插一层组件，两者同时开会以拖拽优先。
   */
  @Prop enableSwipe: boolean = false;
  /** 给第 index 行配的侧滑按钮。仅在 `enableSwipe` 为 true 时调用。 */
  swipeActions?: (item: Object, index: number) => UniSwipeAction[];

  // ---------- 回调 ----------
  /** 下拉刷新。返回的 Promise resolve 后刷新动画自动收起。 */
  onRefresh?: () => Promise<void>;
  /** 触底加载下一页。返回 Promise 时组件会自动管理 loading / 失败态。 */
  onLoadMore?: () => Promise<void> | void;
  /** 错误态点击重试 */
  onRetry?: () => void;
  /** 拖拽排序回调，参数是移动前后的下标，数据重排由调用方完成 */
  onItemMove?: (from: number, to: number) => void;
  /** 点击了某行的某个侧滑按钮 */
  onSwipeAction?: (item: Object, index: number, action: UniSwipeAction, actionIndex: number) => void;
  /**
   * 拖拽事件诊断回调，仅在 `enableDrag` 下触发。
   *
   * 用途是排查「拖不动」：能收到 `longPress` 说明手势进入了拖拽子系统，
   * 收不到则说明手势根本没被识别（多半是 `onMove` 的结构约束没满足）。
   */
  onDragDiagnostic?: (phase: string, from: number, to: number) => void;
  /** 点击某一行 */
  onItemClick?: (item: Object, index: number) => void;

  // ---------- 分组（可选） ----------
  /**
   * 分组数据。传了它，`items` 就会按 {@link groupOf} 归组渲染——
   * 每组一个 `ListItemGroup`，组头由 {@link sectionHeaderBuilder} 描述。
   *
   * 与 `dataSource`（LazyForEach 路径）互斥；同时传时以 `dataSource` 为准。
   */
  @Prop groups: Object[] = [];
  /**
   * 返回某个数据项属于第几个分组（返回下标）。
   *
   * 之所以要这个回调而不是让组件自己猜：组件消费的是拍平的 `items`,
   * 只有调用方知道每一项归属哪一组，硬要组件推导就得约定字段名，
   * 反而限制数据模型。
   */
  groupOf?: (item: Object, index: number) => number;
  /** 分组取稳定 key 的函数，默认用下标。 */
  groupKey?: (section: Object, index: number) => string;
  /** 分组头内容，参数是对应的分组对象。 */
  @BuilderParam sectionHeaderBuilder?: (section: Object, index: number) => void;
  /** 分组底内容。 */
  @BuilderParam sectionFooterBuilder?: (section: Object, index: number) => void;
  /** 分组头是否吸顶 */
  @Prop stickyGroups: boolean = true;

  // ---------- 构建器 ----------
  /** 单行内容。回调参数是数据项与其下标。 */
  @BuilderParam itemBuilder: (item: Object, index: number) => void;
  /**
   * 列表头部，作为 `List` 的第一个 `ListItem`。
   *
   * 典型用法是 Hero 大图 + 统计行 + 吸顶搜索框——它们随列表一起滚动，
   * 但滚动容器仍然由本组件持有，页面里不必重新出现 `List` / `ListItem`。
   *
   * ⚠️ 与 `itemBuilder` 同样的约束：传进来的 `@Builder` 必须用箭头函数包裹，
   * 且不要在内部直接实例化自定义组件（要经由 `@Builder` 方法）。
   */
  @BuilderParam headerBuilder?: () => void;
  /**
   * 紧跟头部、**吸顶**的区块（如搜索框）。滚动时贴住顶部，直到列表滚到底。
   *
   * 实现方式是把它作为**唯一一个** `ListItemGroup` 的 header，所有内容装在这个组里。
   * 因为 `List.sticky` 是「每个组各自吸自己的 header」，只要有第二个带 header 的组，
   * 它的 header 就会被顶替——所以传了本参数时，分组头会退化成普通标题行
   * （不再各自吸顶），以换取吸顶层稳定贴顶。
   *
   * 与 `dataSource`（LazyForEach）不兼容，该场景下会被忽略。
   */
  @BuilderParam stickyHeaderBuilder?: () => void;
  @BuilderParam skeletonBuilder?: () => void;
  @BuilderParam emptyBuilder?: () => void;
  @BuilderParam errorBuilder?: () => void;

  // ---------- 内部状态 ----------
  /** 下拉刷新时**必须**由组件自己持有：绑到 `@Prop` 会被父组件下一次更新用旧值覆盖。 */
  @State private innerRefreshing: boolean = false;
  @State private loadState: UniLoadState = UniLoadState.Idle;
  @State private showTop: boolean = false;
  /** 当前展开侧滑的行下标，-1 表示没有。仅用于回调上报，不做主动互斥（见 UniSwipeItem 文档）。 */
  @State private expandedSwipeIndex: number = -1;
  private scroller: ListScroller = new ListScroller();
  private guard: UniLoadGuard = new UniLoadGuard();

  private swipeActionsOf(item: Object, index: number): UniSwipeAction[] {
    return this.swipeActions !== undefined ? this.swipeActions(item, index) : [];
  }

  // ================= 推导与工具 =================

  private dataCount(): number {
    return this.dataSource !== undefined ? this.dataSource.totalCount() : this.items.length;
  }

  /** 把 `state: Auto` 推导成具体状态；显式指定时原样返回。 */
  private resolvedState(): UniState {
    if (this.state !== UniState.Auto) {
      return this.state;
    }
    if (this.dataCount() > 0) {
      return UniState.Data;
    }
    if (this.loading) {
      return UniState.Loading;
    }
    if (this.errorMessage.length > 0) {
      return UniState.Error;
    }
    return UniState.Empty;
  }

  /**
   * 叠加 `hasMore` 后的底部状态。
   *
   * 这样调用方只要把 `hasMore` 置 false，底部就自动变成「没有更多了」，
   * 不需要自己去同步一个 loadState。
   */
  private footerState(): UniLoadState {
    if (this.loadState === UniLoadState.Idle) {
      return this.hasMore ? UniLoadState.Idle : UniLoadState.NoMore;
    }
    return this.loadState;
  }

  private keyOf(item: Object, index: number): string {
    return this.itemKey !== undefined ? this.itemKey(item, index) : index.toString();
  }

  /**
   * 触发一次「加载更多」。
   *
   * @param force 跳过防抖窗口，供底部「点击重试」使用——重试往往紧接上一次失败，
   *              不跳过就会被自己的防抖挡住而毫无反应。
   */
  private triggerLoadMore(force: boolean): void {
    // 互斥：加载中或已到底不重复触发
    if (this.loadState === UniLoadState.Loading || this.loadState === UniLoadState.NoMore) {
      return;
    }
    if (this.onLoadMore === undefined) {
      return;
    }
    // 时间维度去重：onReachEnd 在 Spring 边缘效果下越界与回弹各触发一次
    if (!this.guard.canTrigger(force)) {
      return;
    }
    this.loadState = UniLoadState.Loading;
    try {
      const result: Promise<void> | void = this.onLoadMore();
      if (result instanceof Promise) {
        result.then(() => {
          this.loadState = this.hasMore ? UniLoadState.Idle : UniLoadState.NoMore;
        }).catch(() => {
          this.loadState = UniLoadState.Failed;
        });
      } else {
        this.loadState = this.hasMore ? UniLoadState.Idle : UniLoadState.NoMore;
      }
    } catch (e) {
      this.loadState = UniLoadState.Failed;
    }
  }

  private triggerRefresh(): void {
    this.innerRefreshing = true;
    if (this.onRefresh === undefined) {
      this.innerRefreshing = false;
      return;
    }
    this.onRefresh().then(() => {
      this.innerRefreshing = false;
    }).catch(() => {
      this.innerRefreshing = false;
    });
  }

  // ================= 构建 =================

  /** 行内容本体，不含 `ListItem` 外壳——外壳由 {@link row} 决定是否套侧滑。 */
  @Builder
  rowContent(item: Object, index: number): void {
    if (this.card) {
      Column() {
        this.itemBuilder(item, index)
      }
      .width('100%')
      .borderRadius(this.theme.cardRadius)
      .backgroundColor(this.theme.bgCard)
      .shadow({
        radius: this.theme.shadowRadius,
        color: this.theme.shadowColor,
        offsetX: 0,
        offsetY: this.theme.shadowOffsetY
      })
      .onClick(() => {
        this.notifyClick(item, index)
      })
    } else {
      Column() {
        this.itemBuilder(item, index)
      }
      .width('100%')
      .backgroundColor(this.theme.bgCard)
      // 朴素模式下用底部分割线代替卡片间距
      .border({ width: { bottom: 1 }, color: this.theme.divider })
      .onClick(() => {
        this.notifyClick(item, index)
      })
    }
  }

  @Builder
  row(item: Object, index: number): void {
    if (this.enableSwipe) {
      // UniSwipeItem 自己产出 ListItem，这里不能再包一层
      UniSwipeItem({
        actions: this.swipeActionsOf(item, index),
        theme: this.theme,
        onAction: (action: UniSwipeAction, actionIndex: number) => {
          if (this.onSwipeAction !== undefined) {
            this.onSwipeAction(item, index, action, actionIndex)
          }
          // 点完按钮立即收起；API 20 没有「只关自己」的接口，只能整表收起
          this.scroller.closeAllSwipeActions()
        },
        onSwipeStateChange: (state: SwipeActionState) => {
          if (state === SwipeActionState.EXPANDED) {
            this.expandedSwipeIndex = index
          } else if (this.expandedSwipeIndex === index) {
            this.expandedSwipeIndex = -1
          }
        },
        contentBuilder: () => {
          this.rowContent(item, index)
        }
      })
    } else {
      ListItem() {
        this.rowContent(item, index)
      }
    }
  }

  private notifyClick(item: Object, index: number): void {
    if (this.onItemClick !== undefined) {
      this.onItemClick(item, index)
    }
  }

  /** 分组头吸顶开关。`List.sticky` 只对 `ListItemGroup` 的 header/footer 生效。 */
  private stickyStyle(): StickyStyle {
    if (!this.stickyGroups) {
      return StickyStyle.None;
    }
    // 固定用 Header。`StickyStyle.BOTH`（API 20 新增）在「吸顶层 + 内容同组」这个
    // 结构下会让 header 不吸顶，实测过；Header 就够用，本组也没有 footer 要吸。
    return StickyStyle.Header;
  }

  private groupIndexOf(section: Object, sectionIndex: number): string {
    return this.groupKey !== undefined ? this.groupKey(section, sectionIndex) : sectionIndex.toString();
  }

  @Builder
  sectionHeader(section: Object, sectionIndex: number): void {
    if (this.sectionHeaderBuilder !== undefined) {
      this.sectionHeaderBuilder(section, sectionIndex)
    }
  }

  @Builder
  sectionFooter(section: Object, sectionIndex: number): void {
    if (this.sectionFooterBuilder !== undefined) {
      this.sectionFooterBuilder(section, sectionIndex)
    }
  }

  /**
   * 头部内容。
   *
   * **不能**在调用点用 `if` 判断有没有传——见 `listBody` 里的注释。
   * 只能进到方法内部再判空。
   */
  @Builder
  headerInner(): void {
    if (this.headerBuilder !== undefined) {
      this.headerBuilder()
    }
  }

  @Builder
  stickyHeaderInner(): void {
    if (this.stickyHeaderBuilder !== undefined) {
      this.stickyHeaderBuilder()
    }
  }

  /**
   * 吸顶层 + 全部内容，包在**同一个** `ListItemGroup` 里。
   *
   * 这是实测出来的唯一可行结构，试错过程记录如下：
   *
   * - 「只有 header、没有 body 的组」：`List.sticky` 是「每个组各自吸自己的 header」，
   *   页面里再有带 header 的分组时，后者的 header 会把它顶掉。
   * - `ListItem.sticky`：**完全无效**。单独写一个最简 List 验证过，滚动后照样滚走
   *   （它标了 deprecated since 9，看来确实不再实现）。
   * - 把内容直接塞进组、组头设成吸顶层：✅ 可行。全局只有一个组，没有被顶替的问题。
   *
   * 组内的分组头改用**加粗标题行**而不是嵌套 `ListItemGroup`——组里不能直接嵌组。
   * 代价是分组头不再有「互相顶替」的吸顶效果，换来搜索框能稳定吸顶。
   */
  @Builder
  stickyHeaderGroup(): void {
    ListItemGroup({
      header: () => { this.stickyHeaderInner() }
    }) {
      if (this.groups.length > 0 && this.groupOf !== undefined) {
        // 分组：标题行 + 该组的数据项
        ForEach(this.groups, (section: Object, sectionIndex: number) => {
          ListItem() {
            this.sectionHeader(section, sectionIndex)
          }
          ForEach(this.items, (item: Object, index: number) => {
            if (this.groupOf !== undefined && this.groupOf(item, index) === sectionIndex) {
              ListItem() {
                this.rowContent(item, index)
              }
            }
          }, (item: Object, index: number) => this.keyOf(item, index))
        }, (section: Object, sectionIndex: number) => this.groupIndexOf(section, sectionIndex))
      } else {
        this.plainItems()
      }
    }
  }

  /** 不带分组的普通项。 */
  @Builder
  plainItems(): void {
    ForEach(this.items, (item: Object, index: number) => {
      this.row(item, index)
    }, (item: Object, index: number) => this.keyOf(item, index))
  }

  /** 按 `groupOf` 把拍平的 items 归到各组，用 ListItemGroup 渲染。 */
  @Builder
  groupedItems(): void {
    ForEach(this.groups, (section: Object, sectionIndex: number) => {
      ListItemGroup({
        header: () => { this.sectionHeader(section, sectionIndex) },
        footer: this.sectionFooterBuilder !== undefined
          ? () => { this.sectionFooter(section, sectionIndex) }
          : undefined
      }) {
        ForEach(this.items, (item: Object, index: number) => {
          // 只渲染属于本组的项
          if (this.groupOf !== undefined && this.groupOf(item, index) === sectionIndex) {
            ListItem() {
              this.rowContent(item, index)
            }
          }
        }, (item: Object, index: number) => this.keyOf(item, index))
      }
    }, (section: Object, sectionIndex: number) => this.groupIndexOf(section, sectionIndex))
  }

  /** 列表主体：数据源 / 拖拽 / 分组 / 普通四种渲染方式。 */
  @Builder
  bodyItems(): void {
    if (this.dataSource !== undefined) {
      LazyForEach(this.dataSource, (item: Object, index: number) => {
        this.row(item, index)
      }, (item: Object, index: number) => this.keyOf(item, index))
    } else if (this.enableDrag && !this.enableSwipe) {
      // 拖拽的硬约束（SDK 文档原文）：onMove 只在父容器是 List、
      // 且**每次 ForEach 迭代直接产出 ListItem** 时生效。
      // 中间隔一层 @Builder（`this.row(...)`）就不满足，所以这里必须是内联的 ListItem。
      ForEach(this.items, (item: Object, index: number) => {
        ListItem() {
          this.rowContent(item, index)
        }
      }, (item: Object, index: number) => this.keyOf(item, index))
        .onMove((from: number, to: number) => {
          if (this.onItemMove !== undefined) {
            this.onItemMove(from, to)
          }
        }, {
          // 诊断用：能收到说明长按确实进入了拖拽子系统
          onLongPress: (index: number) => {
            if (this.onDragDiagnostic !== undefined) {
              this.onDragDiagnostic('longPress', index, index)
            }
          },
          onDragStart: (index: number) => {
            if (this.onDragDiagnostic !== undefined) {
              this.onDragDiagnostic('dragStart', index, index)
            }
          },
          onMoveThrough: (from: number, to: number) => {
            if (this.onDragDiagnostic !== undefined) {
              this.onDragDiagnostic('moveThrough', from, to)
            }
          },
          onDrop: (index: number) => {
            if (this.onDragDiagnostic !== undefined) {
              this.onDragDiagnostic('drop', index, index)
            }
          }
        })
    } else if (this.groups.length > 0 && this.groupOf !== undefined) {
      this.groupedItems()
    } else {
      ForEach(this.items, (item: Object, index: number) => {
        this.row(item, index)
      }, (item: Object, index: number) => this.keyOf(item, index))
    }
  }

  @Builder
  listBody(): void {
    List({ scroller: this.scroller, space: this.card ? this.theme.cardGap : 0 }) {
      // 头部区：随列表滚动移出。内容完全由调用方描述。
      //
      // ⚠️ 这里**刻意不写 `if (this.headerBuilder !== undefined)`**。
      // 实测：把 @BuilderParam 的调用包在 if 分支里，它不会被渲染（且不报错、不崩溃，
      // 就是空白）。必须无条件调用——没传时 `headerInner()` 内部自己什么都不画。
      ListItem() {
        this.headerInner()
      }

      // 有吸顶层时：吸顶层和全部内容包在同一个组里（见 stickyHeaderGroup 的说明）。
      // 没有吸顶层时：走常规分支。
      if (this.stickyHeaderBuilder !== undefined && this.dataSource === undefined) {
        this.stickyHeaderGroup()
      } else {
        this.bodyItems()
      }

      // 底部状态栏：List 没有 footer 选项，只能作为最后一个 ListItem
      if (this.enableLoadMore && this.dataCount() > 0) {
        ListItem() {
          UniFooter({
            loadState: this.footerState(),
            theme: this.theme,
            texts: this.texts,
            onRetry: () => {
              this.triggerLoadMore(true)
            }
          })
        }
      }
    }
    .width('100%')
    .height('100%')
    // Refresh 与内容不足一屏的 List 组合时，必须开 alwaysEnabled 才能下拉
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .scrollBar(BarState.Off)
    // 分组头（以及吸顶搜索框）吸顶
    .sticky(this.stickyStyle())
    .padding({
      left: this.theme.pagePadding,
      right: this.theme.pagePadding,
      bottom: this.theme.bottomInset
    })
    .onReachEnd(() => {
      if (this.enableLoadMore) {
        this.triggerLoadMore(false)
      }
    })
    .onScrollIndex((first: number) => {
      this.showTop = first > 5
    })
    // 注意：这里**不能**用 onScrollStart + closeAllSwipeActions 来做「滚动时收起侧滑」。
    // 实测该回调会被侧滑手势本身触发，导致菜单刚滑开就被自己关掉，侧滑功能彻底失效。
    // 「一次只滑开一个」在 API 20 基线下没有可靠实现（关单个 item 的接口是 API 21 的
    // ListItemSwipeActionManager），详见 UniSwipeItem 的文档说明。
  }

  @Builder
  scrollableBody(): void {
    if (this.enableRefresh) {
      Refresh({ refreshing: $$this.innerRefreshing }) {
        this.listBody()
      }
      .width('100%')
      .height('100%')
      .onRefreshing(() => {
        this.triggerRefresh()
      })
    } else {
      this.listBody()
    }
  }

  /**
   * 非 Data 状态的内容区。
   *
   * 「调用方自定义」的派发必须写在这里而不是塞给 `UniStateView`——`@BuilderParam`
   * 不允许跨组件透传。
   */
  @Builder
  stateArea(): void {
    if (this.resolvedState() === UniState.Loading) {
      if (this.skeletonBuilder !== undefined) {
        this.skeletonBuilder()
      } else {
        this.defaultStateView()
      }
    } else if (this.resolvedState() === UniState.Error) {
      if (this.errorBuilder !== undefined) {
        this.errorBuilder()
      } else {
        this.defaultStateView()
      }
    } else {
      if (this.emptyBuilder !== undefined) {
        this.emptyBuilder()
      } else {
        this.defaultStateView()
      }
    }
  }

  @Builder
  defaultStateView(): void {
    UniStateView({
      state: this.resolvedState(),
      theme: this.theme,
      texts: this.texts,
      errorMessage: this.errorMessage,
      skeletonVariant: UniSkeletonVariant.List,
      onRetry: this.onRetry
    })
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      if (this.resolvedState() === UniState.Data) {
        this.scrollableBody()
        if (this.enableFloatingTop && this.showTop) {
          UniFloatingTop({
            theme: this.theme,
            onTap: () => {
              this.scroller.scrollEdge(Edge.Top)
            }
          })
        }
      } else {
        this.stateArea()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.bgPage)
  }
}
