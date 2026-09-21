import { UniWaterfall, UniTheme, UniTexts } from 'unilist';
import { FeedVO, makeFeed } from '../../model/FeedModel';

/** 瀑布流演示：卡片高度不等，验证错落排列且不重叠。 */
@Component
export struct WaterfallDemo {
  @Prop theme: UniTheme = UniTheme.standard;
  @Consume('uniPathStack') pathStack: NavPathStack;

  @State items: FeedVO[] = [];
  @State columns: number = 2;

  aboutToAppear(): void {
    this.items = makeFeed(16, 11, 0);
  }

  @Builder
  card(item: Object, index: number): void {
    Column() {
      // 上半部分色块，下半部分文字，模拟图文卡片
      Column()
        .width('100%')
        .layoutWeight(1)
        .backgroundColor((item as FeedVO).color)
        .borderRadius({ topLeft: this.theme.cardRadius, topRight: this.theme.cardRadius })
      Column() {
        Text((item as FeedVO).title)
          .fontSize(14)
          .fontColor(this.theme.textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text((item as FeedVO).tail)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.theme.primary)
          .margin({ top: 6 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding(10)
    }
    .width('100%')
    .height('100%')
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text('卡片高度由 itemHeight 回调决定')
            .fontSize(12)
            .fontColor(this.theme.textSecondary)
        }
        .width('100%')
        .padding({ left: 12, top: 8, bottom: 8 })

        UniWaterfall({
          items: this.items,
          columns: this.columns,
          theme: this.theme,
          texts: UniTexts.standard,
          enableRefresh: false,
          enableFloatingTop: true,
          itemKey: (item: Object, index: number) => (item as FeedVO).id,
          // ⚠️ 箭头函数包裹
          itemHeight: (item: Object, index: number) => (item as FeedVO).height,
          itemBuilder: (item: Object, index: number) => {
            this.card(item, index)
          }
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.theme.bgPage)
    }
    .title('瀑布流 UniWaterfall')
    .onBackPressed(() => {
      this.pathStack.pop();
      return true;
    })
  }
}
