import { UniList, UniTheme, UniTexts } from 'unilist';
import { FeedVO, makeFeed } from '../../model/FeedModel';
import { CardRow } from '../gallery/CardRow';

/**
 * 实战页：仿一个真实的商品流页面。
 *
 * 这个页面**完全不出现** `List` / `Refresh` / `ForEach` / `ListItem` ——
 * 下拉刷新、触底加载、底部「没有更多了」、空态错误态、卡片圆角阴影，
 * 全部由 `UniList` 接管。页面只描述两件事：数据和「一行长什么样」。
 */
@Component
export struct FeedPage {
  @Prop theme: UniTheme = UniTheme.standard;
  @Consume('uniPathStack') pathStack: NavPathStack;

  @State items: FeedVO[] = [];
  @State loading: boolean = true;
  @State errorMessage: string = '';
  @State hasMore: boolean = true;
  private page: number = 0;
  private seed: number = 0;

  aboutToAppear(): void {
    // 首屏故意延迟，让骨架屏能被看到
    setTimeout(() => {
      this.items = makeFeed(10, this.seed, 0);
      this.loading = false;
      this.page = 1;
    }, 900);
  }

  /**
   * ⚠️ 必须经由 `@Builder` 方法再调全局 `@Builder`（CardRow）。
   * 直接在传出去的箭头函数体里写 `CardRow(...)` 会抛
   * `Cannot read property observeComponentCreation2 of undefined`。
   */
  @Builder
  cardRow(item: Object, index: number): void {
    CardRow(item as FeedVO, this.theme)
  }

  build() {
    NavDestination() {
      UniList({
        items: this.items,
        loading: this.loading,
        errorMessage: this.errorMessage,
        hasMore: this.hasMore,
        theme: this.theme,
        texts: UniTexts.standard,
        itemKey: (item: Object, index: number) => (item as FeedVO).id,
        onRefresh: () => {
          return new Promise<void>((resolve) => {
            setTimeout(() => {
              this.seed += 7;
              this.items = makeFeed(10, this.seed, 0);
              this.page = 1;
              this.hasMore = true;
              resolve();
            }, 1000);
          });
        },
        onLoadMore: () => {
          return new Promise<void>((resolve) => {
            setTimeout(() => {
              this.page++;
              this.items = this.items.concat(makeFeed(8, this.seed, this.items.length));
              // 第 5 页之后没有更多，底部会自动变成「没有更多了」
              this.hasMore = this.page < 5;
              resolve();
            }, 800);
          });
        },
        itemBuilder: (item: Object, index: number) => {
          this.cardRow(item, index)
        }
      })
    }
    .title('今日好物')
    .hideTitleBar(false)
    .onBackPressed(() => {
      this.pathStack.pop();
      return true;
    })
  }
}
