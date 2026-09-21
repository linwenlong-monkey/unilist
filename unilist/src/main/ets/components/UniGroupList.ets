import { IUniSection, UniLoadState, UniSkeletonVariant, UniState } from './common/UniTypes';
import { UniTheme } from './theme/UniTheme';
import { UniTexts } from './theme/UniTexts';
import { UniStateView } from './internal/UniStateView';
import { UniFooter } from './internal/UniFooter';
import { UniFloatingTop } from './internal/UniFloatingTop';
import { UniLoadGuard } from './internal/UniLoadGuard';

/**
 * 分组列表。
 *
 * 支持吸顶、可折叠、右侧字母索引条。分组头部与行内容都可以自定义。
 *
 * 折叠状态用 `boolean[]` 而不是 `Set`——ArkTS 的 `@State` 对 `Set` 的增删改观测不可靠，
 * 用数组才能保证界面跟着变。
 */
@Component
export struct UniGroupList {
  // ---------- 数据 ----------
  @Prop sections: IUniSection[] = [];

  // ---------- 状态 ----------
  @Prop state: UniState = UniState.Auto;
  @Prop hasMore: boolean = false;
  @Prop loading: boolean = false;
  @Prop errorMessage: string = '';

  // ---------- 外观与能力 ----------
  @Prop theme: UniTheme = UniTheme.standard;
  @Prop texts: UniTexts = UniTexts.standard;
  /** 分组吸顶 */
  @Prop sticky: boolean = true;
  /** 分组可折叠 */
  @Prop collapsible: boolean = false;
  /** 右侧字母索引条。索引项默认取各分组的 title 首字。 */
  @Prop showIndexer: boolean = false;
  /** 索引条上的字符，优先级高于从 title 推导 */
  @Prop indexerValues: string[] = [];
  /** 行与行之间是否画分割线 */
  @Prop divider: boolean = true;
  @Prop enableRefresh: boolean = true;
  @Prop enableLoadMore: boolean = true;
  @Prop enableFloatingTop: boolean = false;

  // ---------- 回调 ----------
  onRefresh?: () => Promise<void>;
  onLoadMore?: () => Promise<void> | void;
  onRetry?: () => void;
  onItemClick?: (item: Object, sectionIndex: number, itemIndex: number) => void;
  /** 分组折叠状态变化 */
  onCollapseChange?: (sectionIndex: number, collapsed: boolean) => void;

  // ---------- 构建器 ----------
  /** 分组内的行。参数依次是：数据项、分组下标、组内下标。 */
  @BuilderParam itemBuilder: (item: Object, sectionIndex: number, itemIndex: number) => void;
  /** 自定义分组头。不传则用内置的标题样式。 */
  @BuilderParam headerBuilder?: (section: IUniSection, sectionIndex: number) => void;
  /** 自定义分组底部。 */
  @BuilderParam footerBuilder?: (section: IUniSection, sectionIndex: number) => void;
  @BuilderParam emptyBuilder?: () => void;
  @BuilderParam errorBuilder?: () => void;

  // ---------- 内部状态 ----------
  @State private innerRefreshing: boolean = false;
  @State private loadState: UniLoadState = UniLoadState.Idle;
  @State private showTop: boolean = false;
  /** 用数组而非 Set，见类文档 */
  @State private collapsed: boolean[] = [];
  @State private indexerSelected: number = 0;
  private scroller: ListScroller = new ListScroller();
  private guard: UniLoadGuard = new UniLoadGuard();

  private totalItems(): number {
    let n = 0;
    for (let i = 0; i < this.sections.length; i++) {
      n += this.sections[i].items.length;
    }
    return n;
  }

  private isCollapsed(sectionIndex: number): boolean {
    return sectionIndex < this.collapsed.length && this.collapsed[sectionIndex];
  }

  private resolvedState(): UniState {
    if (this.state !== UniState.Auto) {
      return this.state;
    }
    if (this.totalItems() > 0) {
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

  private toggleSection(sectionIndex: number): void {
    // 重新赋一个数组，避免原地改元素导致 @State 不感知
    const next: boolean[] = this.collapsed.slice();
    while (next.length <= sectionIndex) {
      next.push(false);
    }
    next[sectionIndex] = !next[sectionIndex];
    this.collapsed = next;
    if (this.onCollapseChange !== undefined) {
      this.onCollapseChange(sectionIndex, next[sectionIndex])
    }
  }

  /** 索引条内容：优先用调用方给的，否则取各组 title 的首字符。 */
  private resolvedIndexerValues(): string[] {
    if (this.indexerValues.length > 0) {
      return this.indexerValues;
    }
    const out: string[] = [];
    for (let i = 0; i < this.sections.length; i++) {
      const t: string | undefined = this.sections[i].title;
      out.push(t !== undefined && t.length > 0 ? t.substring(0, 1) : (i + 1).toString());
    }
    return out;
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

  // ---------------- 构建 ----------------

  @Builder
  defaultHeader(section: IUniSection, sectionIndex: number): void {
    Row() {
      Text(section.title !== undefined ? section.title : '')
        .fontSize(this.theme.fontCaption)
        .fontColor(this.theme.textSecondary)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
      if (this.collapsible) {
        Text(this.isCollapsed(sectionIndex) ? '展开' : '收起')
          .fontSize(this.theme.fontCaption)
          .fontColor(this.theme.textTertiary)
      }
    }
    .width('100%')
    .height(36)
    .padding({ left: this.theme.pagePadding, right: this.theme.pagePadding })
    .backgroundColor(this.theme.bgPage)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      if (this.collapsible) {
        this.toggleSection(sectionIndex)
      }
    })
  }

  @Builder
  groupRow(item: Object, sectionIndex: number, itemIndex: number): void {
    ListItem() {
      Row() {
        Column() {
          this.itemBuilder(item, sectionIndex, itemIndex)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .backgroundColor(this.theme.bgCard)
      .padding({ left: this.theme.pagePadding, right: this.theme.pagePadding })
      .border(this.divider
        ? { width: { bottom: 1 }, color: this.theme.divider }
        : { width: 0 })
      .onClick(() => {
        if (this.onItemClick !== undefined) {
          this.onItemClick(item, sectionIndex, itemIndex)
        }
      })
    }
  }

  @Builder
  sectionHeader(section: IUniSection, sectionIndex: number): void {
    if (this.headerBuilder !== undefined) {
      this.headerBuilder(section, sectionIndex)
    } else {
      this.defaultHeader(section, sectionIndex)
    }
  }

  @Builder
  sectionFooter(section: IUniSection, sectionIndex: number): void {
    // footer 只在调用方提供了 builder 时才存在，否则 ListItemGroup 不该传 footer
    if (this.footerBuilder !== undefined) {
      this.footerBuilder(section, sectionIndex)
    }
  }

  @Builder
  listBody(): void {
    List({ scroller: this.scroller }) {
      ForEach(this.sections, (section: IUniSection, sectionIndex: number) => {
        ListItemGroup({
          header: () => { this.sectionHeader(section, sectionIndex) },
          footer: this.footerBuilder !== undefined
            ? () => { this.sectionFooter(section, sectionIndex) }
            : undefined
        }) {
          if (!this.isCollapsed(sectionIndex)) {
            ForEach(section.items, (item: Object, itemIndex: number) => {
              this.groupRow(item, sectionIndex, itemIndex)
            }, (item: Object, itemIndex: number) => `${sectionIndex}-${itemIndex}`)
          }
        }
        .divider(this.divider
          ? {
            strokeWidth: 1,
            color: this.theme.divider,
            startMargin: this.theme.pagePadding,
            endMargin: this.theme.pagePadding
          }
          : { strokeWidth: 0 })
      }, (section: IUniSection, sectionIndex: number) => `${sectionIndex}-${section.title}`)

      if (this.enableLoadMore && this.totalItems() > 0) {
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
    .sticky(this.sticky ? StickyStyle.Header : StickyStyle.None)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .scrollBar(BarState.Off)
    .padding({ bottom: this.theme.bottomInset })
    .onReachEnd(() => {
      if (this.enableLoadMore) {
        this.triggerLoadMore(false)
      }
    })
    .onScrollIndex((first: number) => {
      this.showTop = first > 5
    })
  }

  @Builder
  indexerBar(): void {
    AlphabetIndexer({ arrayValue: this.resolvedIndexerValues(), selected: this.indexerSelected })
      .font({ size: 12 })
      .itemSize(18)
      .color(this.theme.textTertiary)
      .selectedColor(Color.White)
      .selectedBackgroundColor(this.theme.primary)
      .popupColor(this.theme.bgCard)
      .popupItemBackgroundColor(this.theme.primary)
      .usingPopup(true)
      .onSelect((index: number) => {
        this.indexerSelected = index;
        // List 里每个 ListItemGroup 算一个顶层子节点，所以组下标就是滚动目标
        this.scroller.scrollToIndex(index, true, ScrollAlign.START)
      })
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

  @Builder
  stateArea(): void {
    if (this.resolvedState() === UniState.Loading) {
      this.defaultStateView()
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
        Row() {
          Column() {
            this.scrollableBody()
          }
          .layoutWeight(1)
          .height('100%')

          if (this.showIndexer) {
            this.indexerBar()
          }
        }
        .width('100%')
        .height('100%')

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
