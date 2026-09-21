import { UniList, UniState, UniTheme, UniTexts } from 'unilist';
import { FeedVO, makeFeed } from '../../model/FeedModel';
import { CardRow } from './CardRow';

@Component
export struct StateDemo {
  @Prop theme: UniTheme = UniTheme.standard;
  @Consume('uniPathStack') pathStack: NavPathStack;

  @State state: UniState = UniState.Loading;
  @State items: FeedVO[] = [];
  @State hasMore: boolean = false;

  private options: UniState[] = [
    UniState.Loading, UniState.Empty, UniState.Error, UniState.Data
  ];

  aboutToAppear(): void {
    this.items = makeFeed(5, 3, 0);
  }

  private labelOf(s: UniState): string {
    if (s === UniState.Loading) return '加载中';
    if (s === UniState.Empty) return '空';
    if (s === UniState.Error) return '错误';
    if (s === UniState.Data) return '有数据';
    return '自动';
  }

  @Builder
  picker(): void {
    Row() {
      ForEach(this.options, (s: UniState) => {
        Text(this.labelOf(s))
          .fontSize(14)
          .fontColor(this.state === s ? Color.White : this.theme.textPrimary)
          .backgroundColor(this.state === s ? this.theme.primary : this.theme.bgCard)
          .borderRadius(16)
          .padding({ left: 14, right: 14, top: 6, bottom: 6 })
          .margin({ right: 8 })
          .onClick(() => {
            this.state = s;
          })
      }, (s: UniState) => s.toString())

      Text(this.hasMore ? '有更多' : '没有更多')
        .fontSize(14)
        .fontColor(this.hasMore ? Color.White : this.theme.textPrimary)
        .backgroundColor(this.hasMore ? '#34C759' : this.theme.bgCard)
        .borderRadius(16)
        .padding({ left: 14, right: 14, top: 6, bottom: 6 })
        .onClick(() => {
          this.hasMore = !this.hasMore;
        })
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
  }

  @Builder
  cardRow(item: Object, index: number): void {
    CardRow(item as FeedVO, this.theme)
  }

  build() {
    NavDestination() {
      Column() {
        this.picker()

        UniList({
          state: this.state,
          items: this.state === UniState.Data ? this.items : [],
          hasMore: this.hasMore,
          errorMessage: '网络开小差了，请稍后重试',
          theme: this.theme,
          texts: UniTexts.standard,
          enableRefresh: false,
          itemKey: (item: Object, index: number) => (item as FeedVO).id,
          onRetry: () => {
            this.state = UniState.Loading;
          },
          itemBuilder: (item: Object, index: number) => {
            this.cardRow(item, index)
          }
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.theme.bgPage)
    }
    .title('状态画廊')
    .onBackPressed(() => {
      this.pathStack.pop();
      return true;
    })
  }
}
