import { UniSwipeAction, UniSwipeItem, UniTheme, UniTexts } from 'unilist';
import { FeedVO, makeFeed } from '../../model/FeedModel';
import { CardRow } from './CardRow';

/**
 * 侧滑演示。
 *
 * 这里**直接用 `UniSwipeItem` 包住行**，用来展示它的独立用法——调用方只需要写
 * 「一行长什么样」，`ListItem` 由 `UniSwipeItem` 自己产出。
 * （另一种用法是交给 `UniList({ enableSwipe: true })` 托管，见列表演示页。）
 */
@Component
export struct SwipeDemo {
  @Prop theme: UniTheme = UniTheme.standard;
  @Consume('uniPathStack') pathStack: NavPathStack;

  @State items: FeedVO[] = [];
  @State tip: string = '向左滑动任意一行试试';
  @State twoButton: boolean = false;

  aboutToAppear(): void {
    this.items = makeFeed(8, 17, 0);
  }

  private actionsOf(item: FeedVO, index: number): UniSwipeAction[] {
    if (this.twoButton) {
      return [
        { key: 'delete', text: '删除' },
        { key: 'more', text: '更多', color: '#FF9500' }
      ];
    }
    return [
      { key: 'delete', text: '删除' },
      { key: 'star', text: '收藏', color: '#FF9500' },
      { key: 'mute', text: '免打扰', color: '#8E8E93', width: 84 }
    ];
  }

  @Builder
  rowContent(item: FeedVO, index: number): void {
    CardRow(item, this.theme)
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text(this.tip)
            .fontSize(12)
            .fontColor(this.theme.textSecondary)
            .layoutWeight(1)
          Text(this.twoButton ? '2 按钮' : '3 按钮')
            .fontSize(13)
            .fontColor(this.theme.primary)
            .onClick(() => {
              this.twoButton = !this.twoButton;
            })
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .alignItems(VerticalAlign.Center)

        List({ space: this.theme.cardGap }) {
          ForEach(this.items, (item: FeedVO, index: number) => {
            UniSwipeItem({
              actions: this.actionsOf(item, index),
              theme: this.theme,
              onAction: (action: UniSwipeAction) => {
                if (action.key === 'delete') {
                  const copy: FeedVO[] = this.items.slice();
                  copy.splice(index, 1);
                  this.items = copy;
                  this.tip = `已删除「${item.title}」`;
                } else {
                  this.tip = `对「${item.title}」执行了「${action.text}」`;
                }
              },
              // ⚠️ 箭头函数包裹
              contentBuilder: () => {
                this.rowContent(item, index)
              }
            })
          }, (item: FeedVO) => item.id)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .padding({ left: this.theme.pagePadding, right: this.theme.pagePadding, bottom: 20 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.theme.bgPage)
    }
    .title('侧滑 UniSwipeItem')
    .onBackPressed(() => {
      this.pathStack.pop();
      return true;
    })
  }
}
