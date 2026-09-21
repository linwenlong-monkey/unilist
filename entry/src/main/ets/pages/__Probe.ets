import { UniList, UniSwipeAction, UniTheme, UniTexts } from 'unilist';
import { hilog } from '@kit.PerformanceAnalysisKit';

const D = 0x9999;

@Entry
@Component
struct ProbePage {
  @State items: string[] = [];
  @State hasMore: boolean = false;
  @State theme: UniTheme = UniTheme.standard;
  @State texts: UniTexts = UniTexts.standard;
  @State log: string = 'swipe a row';

  aboutToAppear(): void {
    const out: string[] = [];
    for (let i = 1; i <= 10; i++) {
      out.push(`消息 ${i}`);
    }
    this.items = out;
  }

  @Builder
  row(item: Object, index: number): void {
    Column() {
      Text(item as string)
        .fontSize(16)
        .fontColor(this.theme.textPrimary)
      Text(`副标题 ${index}`)
        .fontSize(13)
        .fontColor(this.theme.textSecondary)
        .margin({ top: 4 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(12)
  }

  build() {
    Column() {
      Text(this.log).fontSize(13).fontColor(this.theme.textPrimary).height(36)

      UniList({
        items: this.items,
        hasMore: this.hasMore,
        theme: this.theme,
        texts: this.texts,
        enableRefresh: false,
        enableLoadMore: false,
        enableSwipe: false,
        swipeActions: (item: Object, index: number) => {
          const acts: UniSwipeAction[] = [
            { key: 'delete', text: '删除' },
            { key: 'more', text: '更多', color: '#FF9500' }
          ];
          return acts;
        },
        onSwipeAction: (item: Object, index: number, action: UniSwipeAction, ai: number) => {
          this.log = `tapped ${action.key} on index ${index}`;
          hilog.info(D, 'PROBE', 'swipe action %{public}s on %{public}d', action.key, index);
        },
        itemBuilder: (item: Object, index: number) => {
          this.row(item, index)
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.bgPage)
  }
}
