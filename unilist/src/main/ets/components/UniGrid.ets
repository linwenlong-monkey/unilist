import { UniItemKey, UniLoadState, UniSkeletonVariant, UniState } from './common/UniTypes';
import { UniTheme } from './theme/UniTheme';
import { UniTexts } from './theme/UniTexts';
import { UniStateView } from './internal/UniStateView';
import { UniFooter } from './internal/UniFooter';
import { UniFloatingTop } from './internal/UniFloatingTop';
import { UniLoadGuard } from './internal/UniLoadGuard';

/**
 * 网格列表。
 *
 * 与 {@link UniList} 同构，差别只在滚动容器是 `Grid`。注意
 * {@link columns} 是真的生效的——旧版本这个属性声明了却从未被 `build()` 使用，
 * 调用方传多少列都落进黑洞，实际列数由自己手写的 `columnsTemplate` 决定。
 */
@Component
export struct UniGrid {
  // ---------- 数据 ----------
  @Prop items: Object[] = [];
  /** 大数据量数据源，走 `LazyForEach`，优先级高于 `items`。 */
  dataSource?: IDataSource;
  itemKey?: UniItemKey;

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
  /** 每个格子是否套卡片样式。 */
  @Prop card: boolean = true;
  /** 格子高度。网格不像瀑布流能自适应高度，需要调用方给个统一值。 */
  @Prop itemHeight: number = 140;

  // ---------- 能力开关 ----------
  @Prop enableRefresh: boolean = true;
  @Prop enableLoadMore: boolean = true;
  @Prop enableFloatingTop: boolean = false;

  // ---------- 回调 ----------
  onRefresh?: () => Promise<void>;
  onLoadMore?: () => Promise<void> | void;
  onRetry?: () => void;
  /** 点击某个格子 */
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
  cell(item: Object, index: number): void {
    GridItem() {
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
    .height(this.itemHeight)
  }

  @Builder
  footerItem(): void {
    GridItem() {
      UniFooter({
        loadState: this.footerState(),
        theme: this.theme,
        texts: this.texts,
        onRetry: () => {
          this.triggerLoadMore(true)
        }
      })
    }
    // 让底部状态横跨整行，否则它只会占一格
    .columnStart(0)
    .columnEnd(this.columns - 1)
  }

  @Builder
  gridBody(): void {
    Grid(this.scroller) {
      if (this.dataSource !== undefined) {
        LazyForEach(this.dataSource, (item: Object, index: number) => {
          this.cell(item, index)
        }, (item: Object, index: number) => this.keyOf(item, index))
      } else {
        ForEach(this.items, (item: Object, index: number) => {
          this.cell(item, index)
        }, (item: Object, index: number) => this.keyOf(item, index))
      }

      if (this.enableLoadMore && this.dataCount() > 0) {
        this.footerItem()
      }
    }
    .columnsTemplate(`repeat(${this.columns}, 1fr)`)
    .columnsGap(this.theme.cardGap)
    .rowsGap(this.theme.cardGap)
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
        this.gridBody()
      }
      .width('100%')
      .height('100%')
      .onRefreshing(() => {
        this.triggerRefresh()
      })
    } else {
      this.gridBody()
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
