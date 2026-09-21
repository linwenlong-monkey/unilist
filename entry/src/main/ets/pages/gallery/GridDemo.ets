import { UniGrid, UniTheme, UniTexts } from 'unilist';
import { FeedVO, makeFeed } from '../../model/FeedModel';

/** 网格演示：列数可以实时改，验证 `UniGrid.columns` 真的生效。 */
@Component
export struct GridDemo {
  @Prop theme: UniTheme = UniTheme.standard;
  @Consume('uniPathStack') pathStack: NavPathStack;

  @State items: FeedVO[] = [];
  @State columns: number = 2;

  aboutToAppear(): void {
    this.items = makeFeed(12, 5, 0);
  }

  @Builder
  cell(item: Object, index: number): void {
    Column() {
      Text((item as FeedVO).title.substring(0, 1))
        .fontSize(24)
        .fontColor(Color.White)
      Text((item as FeedVO).tail)
        .fontSize(13)
        .fontColor('#FFFFFFDD')
        .margin({ top: 6 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor((item as FeedVO).color)
  }

  @Builder
  picker(): void {
    Row() {
      ForEach([1, 2, 3, 4], (n: number) => {
        Text(`${n} 列`)
          .fontSize(14)
          .fontColor(this.columns === n ? Color.White : this.theme.textPrimary)
          .backgroundColor(this.columns === n ? this.theme.primary : this.theme.bgCard)
          .borderRadius(16)
          .padding({ left: 14, right: 14, top: 6, bottom: 6 })
          .margin({ right: 8 })
          .onClick(() => {
            this.columns = n;
          })
      }, (n: number) => n.toString())
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
  }

  build() {
    NavDestination() {
      Column() {
        this.picker()
        UniGrid({
          items: this.items,
          columns: this.columns,
          theme: this.theme,
          texts: UniTexts.standard,
          itemHeight: 120,
          enableRefresh: false,
          enableFloatingTop: true,
          itemKey: (item: Object, index: number) => (item as FeedVO).id,
          itemBuilder: (item: Object, index: number) => {
            this.cell(item, index)
          }
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.theme.bgPage)
    }
    .title('网格 UniGrid')
    .onBackPressed(() => {
      this.pathStack.pop();
      return true;
    })
  }
}
