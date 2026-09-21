import { UniList, UniTheme, UniTexts } from 'unilist';
import { makeSections, PICK_PHOTOS, PHOTOS, TripSection, TripVO, HERO_PHOTO } from '../../model/TripModel';
import { TripGroupHeader, TripHero, TripPickCard, TripRow, TripSearchBar, TripSectionTitle, TripStats } from './TripCards';

/**
 * 实战页：旅行目的地。
 *
 * 这是本工程**嵌套结构最复杂**的页面，用来验证「组件接管容器」能撑住真实场景：
 *
 * ```
 * Refresh（下拉刷新，由 UniList 内置）
 * └─ List（滚动容器，由 UniList 内置；sticky(Header)）
 *    ├─ ListItem          头部：Hero 大图 + 统计行（随滚动移出）
 *    ├─ ListItemGroup ①   header = 吸顶搜索框，body = 「精选推荐」横滑
 *    └─ ListItemGroup ②…N header = 地区名（吸顶），body = 目的地卡片
 * ```
 *
 * 页面里**没有** `List` / `Refresh` / `ForEach` / `ListItem` / `ListItemGroup`。
 *
 * ⚠️ 所有传给库的 `@BuilderParam` 都走 `this.xxx` 方法（不是裸引用、
 * 也不在箭头里直接实例化自定义组件），这是本项目踩出来的硬约束。
 */
@Component
export struct FeedPage {
  @Prop theme: UniTheme = UniTheme.standard;
  @Consume('uniPathStack') pathStack: NavPathStack;

  @State sections: TripSection[] = [];
  @State loading: boolean = true;
  @State errorMessage: string = '';
  @State hasMore: boolean = true;
  /** Hero 轮换用的图下标，下拉刷新时会换一张 */
  @State heroPhoto: number = HERO_PHOTO;
  private page: number = 1;

  aboutToAppear(): void {
    setTimeout(() => {
      this.sections = makeSections();
      this.loading = false;
    }, 800);
  }

  /** 所有目的地拍平，供 `UniList` 遍历；`itemBuilder` 再按 id 反查所属分组。 */
  private allTrips(): TripVO[] {
    const out: TripVO[] = [];
    for (let i = 0; i < this.sections.length; i++) {
      const ts: TripVO[] = this.sections[i].trips;
      for (let j = 0; j < ts.length; j++) {
        out.push(ts[j]);
      }
    }
    return out;
  }

  private totalDays(): number {
    let n = 0;
    const ts: TripVO[] = this.allTrips();
    for (let i = 0; i < ts.length; i++) {
      n += ts[i].days;
    }
    return n;
  }

  // ================= 构建器 =================

  /** 头部：Hero 大图 + 统计行。随列表滚动移出。 */
  @Builder
  header(): void {
    Column() {
      TripHero(this.theme, this.heroPhoto, '去看世界的另一面', '精选 8 个目的地 · 2026 春季精选')
      TripStats(this.theme, this.allTrips().length, 3, this.totalDays())
    }
    .width('100%')
  }

  /** 吸顶层：搜索框。滚动时贴住顶部。 */
  @Builder
  stickySearch(): void {
    Column() {
      TripSearchBar(this.theme)
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    // 吸顶时有内容从下面穿过，必须是不透明底色
    .backgroundColor(this.theme.bgPage)
  }

  /** 分组头：地区名。 */
  @Builder
  groupHeader(section: TripSection): void {
    TripGroupHeader(this.theme, section.title, section.subtitle, section.trips.length)
  }

  /** 目的地卡片行。 */
  @Builder
  tripRow(item: Object, index: number): void {
    TripRow(this.theme, item as TripVO)
  }

  build() {
    NavDestination() {
      UniList({
        items: this.allTrips(),
        loading: this.loading,
        errorMessage: this.errorMessage,
        hasMore: this.hasMore,
        theme: this.theme,
        texts: UniTexts.standard,
        // 分组数据 + 分组头 + 吸顶
        groups: this.sections,
        groupOf: (item: Object) => this.sections.findIndex((s: TripSection) =>
          s.trips.some((t: TripVO) => t.id === (item as TripVO).id)),
        groupKey: (section: Object) => (section as TripSection).title,
        sectionHeaderBuilder: (section: Object) => {
          this.groupHeader(section as TripSection)
        },
        stickyGroups: true,
        // 头部 + 吸顶搜索框
        headerBuilder: () => {
          this.header()
        },
        stickyHeaderBuilder: () => {
          this.stickySearch()
        },
        itemKey: (item: Object, index: number) => (item as TripVO).id,
        onRefresh: () => {
          return new Promise<void>((resolve) => {
            setTimeout(() => {
              this.sections = makeSections();
              // 刷新时换一张 Hero，让「确实重新加载了」看得见
              this.heroPhoto = (this.heroPhoto + 1) % PHOTOS.length;
              this.page = 1;
              this.hasMore = true;
              resolve();
            }, 900);
          });
        },
        onLoadMore: () => {
          return new Promise<void>((resolve) => {
            setTimeout(() => {
              this.page++;
              // 示例数据有限，第 2 页之后到底
              this.hasMore = this.page < 2;
              resolve();
            }, 700);
          });
        },
        onItemClick: (item: Object, index: number) => {
          this.pathStack.pushPath({
            name: 'tripDetail',
            param: item as TripVO
          });
        },
        itemBuilder: (item: Object, index: number) => {
          this.tripRow(item, index)
        }
      })
    }
    .title('')
    .hideTitleBar(false)
    .onBackPressed(() => {
      this.pathStack.pop();
      return true;
    })
  }
}
