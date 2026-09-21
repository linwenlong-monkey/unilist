import { UniItemKey, UniLoadState, UniSkeletonVariant, UniState } from './common/UniTypes';
import { UniTheme } from './theme/UniTheme';
import { UniTexts } from './theme/UniTexts';
import { UniStateView } from './internal/UniStateView';
import { UniFooter } from './internal/UniFooter';
import { UniFloatingTop } from './internal/UniFloatingTop';
import { UniLoadGuard } from './internal/UniLoadGuard';

/** 取某个瀑布流卡片的高度。卡片的图文比例由调用方决定，组件不自作主张。 */
export type UniFlowHeight = (item: Object, index: number) => number;

/**
 * 瀑布流。
 *
 * `FlowItem` **必须显式设置 height**，布局引擎靠它计算每张卡片的位置；只在内部
 * 组件上设高度会导致卡片重叠。这是本工程踩过的坑，组件内已严格遵守：
 * 见 {@link flowCell} 上挂的 `.height(...)`，内部组件一律用 `height('100%')` 填充。
 *
 * 与大数据的组合：`dataSource` 走 `LazyForEach`，`FlowItem` 的高度由 {@link itemHeight}
 * 按需算出。
 */
@Component
export struct UniWaterfall {
  // ---------- 数据 ----------
  @Prop items: Object[] = [];
  dataSource?: IDataSource;
  itemKey?: UniItemKey;
  /** **必填**：每张卡片的高度。 */
  itemHeight?: UniFlowHeight;

  // ---------- 状态 ----------
  @Prop state: UniState = UniState.Auto;
  @Prop hasMore: boolean = false;
  @Prop loading: boolean = false;
  @Prop errorMessage: string = '';

  // ---------- 外观 ----------
  @Prop theme: UniTheme = UniTheme.standard;
  @Prop texts: UniTexts = UniTexts.standard;
  /** 列数。运行时改它会立刻重排。 */
  @Prop columns: number = 2;
  @Prop card: boolean = true;
  /** 卡片间距，同时作用于横向与纵向 */
  @Prop gap: number = 8;

  // ---------- 能力开关 ----------
  @Prop enableRefresh: boolean = true;
  @Prop enableLoadMore: boolean = true;
  @Prop enableFloatingTop: boolean = false;

  // ---------- 回调 ----------
  onRefresh?: () => Promise<void>;
  onLoadMore?: () => Promise<void> | void;
  onRetry?: () => void;
  onItemClick?: (item: Object, index: number) => void;

  // ---------- 构建器 ----------
  @BuilderParam itemBuilder: (item: Object, index: number) => void;
  @BuilderParam skeletonBuilder?: () => void;
  @BuilderParam emptyBuilder?: () => void;
  @BuilderParam errorBuilder?: () => void;

  // ---------- 内部状态 ----------
  @State private innerRefreshing: boolean = false;
  @State private loadState: UniLoadState = UniLoadState.Idle;
  @State private showTop: boolean = false;
  private scroller: Scroller = new Scroller();
  private guard: UniLoadGuard = new UniLoadGuard();

  private dataCount(): number {
    return this.dataSource !== undefined ? this.dataSource.totalCount() : this.items.length;
  }

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

  private footerState(): UniLoadState {
    if (this.loadState === UniLoadState.Idle) {
      return this.hasMore ? UniLoadState.Idle : UniLoadState.NoMore;
    }
    return this.loadState;
  }

  private keyOf(item: Object, index: number): string {
    return this.itemKey !== undefined ? this.itemKey(item, index) : index.toString();
  }

  /** 没有传 itemHeight 时给个兜底高度，避免布局塌陷。 */
  private heightOf(item: Object, index: number): number {
    return this.itemHeight !== undefined ? this.itemHeight(item, index) : 160;
  }

  private triggerLoadMore(force: boolean): void {
    if (this.loadState === UniLoadState.Loading || this.loadState === UniLoadState.NoMore) {
      return;
    }
    if (this.onLoadMore === undefined) {
      return;
    }
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

  @Builder
  flowCell(item: Object, index: number): void {
    // height 必须挂在 FlowItem 上，内部组件用 100% 填充
    FlowItem() {
      Column() {
        this.itemBuilder(item, index)
      }
      .width('100%')
      .height('100%')
      .borderRadius(this.card ? this.theme.cardRadius : 0)
      .backgroundColor(this.card ? this.theme.bgCard : Color.Transparent)
      .clip(true)
      .onClick(() => {
        if (this.onItemClick !== undefined) {
          this.onItemClick(item, index)
        }
      })
    }
    .width('100%')
    .height(this.heightOf(item, index))
  }

  @Builder
  flowFooter(): void {
    UniFooter({
      loadState: this.footerState(),
      theme: this.theme,
      texts: this.texts,
      onRetry: () => {
        this.triggerLoadMore(true)
      }
    })
  }

  @Builder
  flowBody(): void {
    WaterFlow({
      scroller: this.scroller,
      // ⚠️ 必须用箭头函数包裹：直接传 `this.flowFooter` 会丢失 this 绑定，运行期抛
      // "Cannot read property observeComponentCreation2 of undefined"。这与
      // @BuilderParam 的传参陷阱是同一个根因——凡是把 @Builder 当值传出去，都要包一层。
      footer: this.enableLoadMore && this.dataCount() > 0 ? () => { this.flowFooter() } : undefined
    }) {
      if (this.dataSource !== undefined) {
        LazyForEach(this.dataSource, (item: Object, index: number) => {
          this.flowCell(item, index)
        }, (item: Object, index: number) => this.keyOf(item, index))
      } else {
        ForEach(this.items, (item: Object, index: number) => {
          this.flowCell(item, index)
        }, (item: Object, index: number) => this.keyOf(item, index))
      }
    }
    .columnsTemplate(`repeat(${this.columns}, 1fr)`)
    .columnsGap(this.gap)
    .rowsGap(this.gap)
    // WaterFlow 用的是 FlexDirection，和 Grid 的 GridDirection 不是一回事
    .layoutDirection(FlexDirection.Column)
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .scrollBar(BarState.Off)
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
      this.showTop = first > 12
    })
  }

  @Builder
  scrollableBody(): void {
    if (this.enableRefresh) {
      Refresh({ refreshing: $$this.innerRefreshing }) {
        this.flowBody()
      }
      .width('100%')
      .height('100%')
      .onRefreshing(() => {
        this.triggerRefresh()
      })
    } else {
      this.flowBody()
    }
  }

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
      skeletonVariant: UniSkeletonVariant.Grid,
      skeletonColumns: this.columns,
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
