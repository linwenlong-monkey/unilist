import { UniTheme } from 'unilist';
import { PHOTOS, TripVO, tripMeta } from '../../model/TripModel';


@Component
export struct TripDetailPage {
  @Prop theme: UniTheme = UniTheme.standard;
  @Consume('uniPathStack') pathStack: NavPathStack;
  @Prop trip: TripVO = new TripVO('', '', '', 0, 0, 0, 0, [], []);
  @State favorited: boolean = false;

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Scroll() {
          Column() {
            // ---------- Hero 轮播 ----------
            Scroll() {
              Row() {
                ForEach(this.trip.gallery, (photoIndex: number, i: number) => {
                  Image(PHOTOS[photoIndex].res)
                    .width(280)
                    .height(300)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(this.theme.cardRadius)
                    .margin({ right: 10 })
                }, (photoIndex: number, i: number) => `${photoIndex}-${i}`)
              }
              .padding({ left: 16, right: 16 })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
            .height(300)

            // ---------- 标题信息 ----------
            Column() {
              Row() {
                Text(this.trip.name)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.theme.textPrimary)
                  .layoutWeight(1)
                Text(this.favorited ? '♥' : '♡')
                  .fontSize(24)
                  .fontColor(this.favorited ? '#FF3B30' : this.theme.textTertiary)
                  .onClick(() => {
                    this.favorited = !this.favorited;
                  })
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)

              Text(this.trip.tagline)
                .fontSize(14)
                .fontColor(this.theme.textSecondary)
                .margin({ top: 6 })

              Row() {
                Text(`★ ${this.trip.rating}`)
                  .fontSize(14)
                  .fontColor('#FF9500')
                Text(tripMeta(this.trip))
                  .fontSize(14)
                  .fontColor(this.theme.textSecondary)
                  .margin({ left: 12 })
                Text(`¥${this.trip.price} 起`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.theme.primary)
                  .margin({ left: 12 })
              }
              .margin({ top: 12 })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding({ left: 16, right: 16, top: 18 })

            // ---------- 行程亮点 ----------
            Column() {
              Text('行程亮点')
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.theme.textPrimary)

              ForEach(this.trip.highlights, (h: string, i: number) => {
                Row() {
                  Text(`${i + 1}`)
                    .fontSize(12)
                    .fontColor(Color.White)
                    .width(20)
                    .height(20)
                    .borderRadius(10)
                    .backgroundColor(this.theme.primary)
                    .textAlign(TextAlign.Center)
                  Text(h)
                    .fontSize(14)
                    .fontColor(this.theme.textSecondary)
                    .layoutWeight(1)
                    .margin({ left: 10 })
                }
                .width('100%')
                .padding({ top: 10, bottom: 10 })
                .alignItems(VerticalAlign.Center)
              }, (h: string, i: number) => `${i}-${h}`)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding({ left: 16, right: 16, top: 24 })
            // 给底部操作栏留出空间
            .padding({ bottom: 100 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .backgroundColor(this.theme.bgPage)

        // ---------- 底部固定操作栏 ----------
        Row() {
          Column() {
            Text(`¥${this.trip.price}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.theme.textPrimary)
            Text('起 / 人')
              .fontSize(11)
              .fontColor(this.theme.textTertiary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Button('立即预订')
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor(this.theme.primary)
            .borderRadius(24)
            .height(46)
            .padding({ left: 32, right: 32 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor(this.theme.bgCard)
        .alignItems(VerticalAlign.Center)
        .shadow({ radius: 12, color: '#14000000', offsetX: 0, offsetY: -2 })
      }
      .width('100%')
      .height('100%')
    }
    .title('')
    .hideTitleBar(false)
    .onBackPressed(() => {
      this.pathStack.pop();
      return true;
    })
  }
}
