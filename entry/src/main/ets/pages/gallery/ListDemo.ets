import { UniList, UniSwipeAction, UniTheme, UniTexts } from 'unilist';
import { FeedVO, makeFeed } from '../../model/FeedModel';
import { CardRow } from './CardRow';

/** 列表演示：下拉刷新 + 触底加载 + 侧滑 + 拖拽 + 浮动按钮。 */
@Component
export struct ListDemo {
  @Prop theme: UniTheme = UniTheme.standard;
  @Consume('uniPathStack') pathStack: NavPathStack;

  @State items: FeedVO[] = [];
  @State loading: boolean = true;
  @State errorMessage: string = '';
  @State hasMore: boolean = true;
  @State enableDrag: boolean = false;
  @State tip: string = '';
  private page: number = 1;
  /** 用来让每页数据长得不一样，刷新后能肉眼看出确实换了 */
  private seed: number = 0;

  aboutToAppear(): void {
    setTimeout(() => {
      this.items = makeFeed(8, this.seed, 0);
      this.loading = false;
      this.page = 1;
    }, 900);
  }

  /**
   * ⚠️ 必须经由 `@Builder` 方法再调全局 `@Builder`（CardRow）。
   * 直接在传出去的箭头函数体里写 `CardRow(...)` 会抛
   * `Cannot read property observeComponentCreation2 of undefined`——
   * 箭头函数体不是组件的构建作用域，拿不到渲染上下文。
   */
  @Builder
  cardRow(item: Object, index: number): void {
    CardRow(item as FeedVO, this.theme)
  }

  private swipeActions(item: FeedVO, index: number): UniSwipeAction[] {
    return [
      { key: 'delete', text: '删除' },
      { key: 'star', text: '收藏', color: '#FF9500' },
      { key: 'mute', text: '免打扰', color: '#8E8E93', width: 84 }
    ];
  }

  build() {
    Column() {
      NavDestination() {
        Column() {
          if (this.tip.length > 0) {
            Text(this.tip)
              .fontSize(12)
              .fontColor(this.theme.textSecondary)
              .width('100%')
              .padding({ left: 12, top: 6, bottom: 6 })
          }
          Row() {
            Text(this.enableDrag ? '拖拽：开（长按行可拖动）' : '拖拽：关')
              .fontSize(13)
              .fontColor(this.theme.primary)
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.enableDrag })
              .onChange((on: boolean) => {
                this.enableDrag = on;
                this.tip = on ? '长按任意行拖动排序' : '拖拽已关闭';
              })
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
          .alignItems(VerticalAlign.Center)

          UniList({
            items: this.items,
            loading: this.loading,
            errorMessage: this.errorMessage,
            hasMore: this.hasMore,
            theme: this.theme,
            texts: UniTexts.standard,
            enableDrag: this.enableDrag,
            enableSwipe: !this.enableDrag,
            swipeActions: (item: Object, index: number) => this.swipeActions(item as FeedVO, index),
            itemKey: (item: Object, index: number) => (item as FeedVO).id,
            onRefresh: () => {
              return new Promise<void>((resolve) => {
                setTimeout(() => {
                  this.seed += 7;
                  this.items = makeFeed(8, this.seed, 0);
                  this.page = 1;
                  this.hasMore = true;
                  this.tip = '已刷新';
                  resolve();
                }, 900);
              });
            },
            onLoadMore: () => {
              return new Promise<void>((resolve) => {
                setTimeout(() => {
                  this.page++;
                  const next = makeFeed(6, this.seed, this.items.length);
                  this.items = this.items.concat(next);
                  this.hasMore = this.page < 4;
                  resolve();
                }, 700);
              });
            },
            onSwipeAction: (item: Object, index: number, action: UniSwipeAction) => {
              if (action.key === 'delete') {
                const copy: FeedVO[] = this.items.slice();
                copy.splice(index, 1);
                this.items = copy;
                this.tip = `已删除第 ${index + 1} 项`;
              } else {
                this.tip = `点了「${action.text}」`;
              }
            },
            onItemMove: (from: number, to: number) => {
              const copy: FeedVO[] = this.items.slice();
              const moved = copy.splice(from, 1)[0];
              copy.splice(to, 0, moved);
              this.items = copy;
              this.tip = `已把第 ${from + 1} 项移到第 ${to + 1} 位`;
            },
            itemBuilder: (item: Object, index: number) => {
              // ⚠️ 箭头函数包裹 + 经由 @Builder 方法，两者缺一不可
              this.cardRow(item, index)
            }
          })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.theme.bgPage)
      }
      .title('列表 UniList')
      .onBackPressed(() => {
        this.pathStack.pop();
        return true;
      })
    }
    .width('100%')
    .height('100%')
  }
}
