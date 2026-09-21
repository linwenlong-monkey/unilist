import { UniTheme } from 'unilist';
import { PHOTOS, TripVO, tripMeta } from '../../model/TripModel';

/** Hero 大图：整幅铺满，底部渐变压暗后再压白色标题。 */
@Builder
export function TripHero(theme: UniTheme, photoIndex: number, title: string, subtitle: string) {
  Stack({ alignContent: Alignment.BottomStart }) {
    Image(PHOTOS[photoIndex].res)
      .width('100%')
      .height('100%')
      .objectFit(ImageFit.Cover)
      .interpolation(ImageInterpolation.High)

    Column()
      .width('100%')
      .height('100%')
      .linearGradient({
        angle: 180,
        colors: [['#00000000', 0.0], ['#00000000', 0.45], ['#B3000000', 1.0]]
      })

    Column() {
      Text(title)
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
      Text(subtitle)
        .fontSize(14)
        .fontColor('#E6FFFFFF')
        .margin({ top: 6 })
    }
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 20, right: 20, bottom: 28 })
  }
  .width('100%')
  .height(320)
}

/** Hero 下方的一行统计。 */
@Builder
export function TripStats(theme: UniTheme, destinations: number, favorites: number, days: number) {
  Row() {
    Column() {
      Text(`${destinations}`)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(theme.textPrimary)
      Text('个目的地')
        .fontSize(12)
        .fontColor(theme.textTertiary)
        .margin({ top: 2 })
    }
    .layoutWeight(1)

    Column() {
      Text(`${favorites}`)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(theme.textPrimary)
      Text('个收藏')
        .fontSize(12)
        .fontColor(theme.textTertiary)
        .margin({ top: 2 })
    }
    .layoutWeight(1)

    Column() {
      Text(`${days}`)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(theme.textPrimary)
      Text('天行程')
        .fontSize(12)
        .fontColor(theme.textTertiary)
        .margin({ top: 2 })
    }
    .layoutWeight(1)
  }
  .width('100%')
  .padding({ top: 16, bottom: 16 })
  .backgroundColor(theme.bgPage)
}

/** 搜索框圆角，取高度的一半做成胶囊形。 */
const SEARCH_BAR_RADIUS: number = 23;

/** 吸顶搜索框。 */
@Builder
export function TripSearchBar(theme: UniTheme) {
  Row() {
    Text('🔍')
      .fontSize(15)
    Text('搜索目的地、玩法')
      .fontSize(14)
      .fontColor(theme.textTertiary)
      .layoutWeight(1)
      .margin({ left: 8 })
    Text('筛选')
      .fontSize(13)
      .fontColor(theme.primary)
  }
  .width('100%')
  .height(46)
  .padding({ left: 14, right: 14 })
  .borderRadius(SEARCH_BAR_RADIUS)
  .backgroundColor(theme.bgCard)
  .alignItems(VerticalAlign.Center)
  .shadow({ radius: 6, color: '#14000000', offsetX: 0, offsetY: 2 })
}

/** 区块小标题，如「精选推荐」。 */
@Builder
export function TripSectionTitle(theme: UniTheme, title: string, subtitle: string) {
  Row() {
    Column() {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(theme.textPrimary)
      if (subtitle.length > 0) {
        Text(subtitle)
          .fontSize(12)
          .fontColor(theme.textTertiary)
          .margin({ top: 2 })
      }
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
  }
  .width('100%')
}

/** 「精选推荐」里的一张竖卡片。 */
@Builder
export function TripPickCard(theme: UniTheme, photoIndex: number, name: string, price: number) {
  Column() {
    Image(PHOTOS[photoIndex].res)
      .width('100%')
      .height(120)
      .objectFit(ImageFit.Cover)
      .borderRadius({ topLeft: theme.cardRadius, topRight: theme.cardRadius })
    Column() {
      Text(name)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(theme.textPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(`¥${price} 起`)
        .fontSize(12)
        .fontColor(theme.primary)
        .margin({ top: 4 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(10)
  }
  .width(150)
  .borderRadius(theme.cardRadius)
  .backgroundColor(theme.bgCard)
  .clip(true)
  .shadow({ radius: 6, color: '#0F000000', offsetX: 0, offsetY: 2 })
}

/** 分组内的一个目的地行：左侧方形图 + 右侧信息。 */
@Builder
export function TripRow(theme: UniTheme, trip: TripVO) {
  Row() {
    Image(PHOTOS[trip.photo].res)
      .width(96)
      .height(96)
      .objectFit(ImageFit.Cover)
      .borderRadius(10)

    Column() {
      Text(trip.name)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(theme.textPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(trip.tagline)
        .fontSize(12)
        .fontColor(theme.textSecondary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 4 })
      Row() {
        Text(`★ ${trip.rating}`)
          .fontSize(12)
          .fontColor('#FF9500')
        Text(tripMeta(trip))
          .fontSize(12)
          .fontColor(theme.textTertiary)
          .margin({ left: 10 })
      }
      .margin({ top: 6 })
      Text(`¥${trip.price} 起`)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(theme.primary)
        .margin({ top: 6 })
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
    .margin({ left: 12 })
  }
  .width('100%')
  .padding(10)
  .alignItems(VerticalAlign.Top)
}

/** 分组头：左色条 + 标题 + 副标题 + 数量。 */
@Builder
export function TripGroupHeader(theme: UniTheme, title: string, subtitle: string, count: number) {
  Row() {
    Column()
      .width(3)
      .height(28)
      .borderRadius(2)
      .backgroundColor(theme.primary)

    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(theme.textPrimary)
      if (subtitle.length > 0) {
        Text(subtitle)
          .fontSize(11)
          .fontColor(theme.textTertiary)
          .margin({ top: 2 })
      }
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
    .margin({ left: 10 })

    Text(`${count} 条`)
      .fontSize(12)
      .fontColor(theme.textTertiary)
  }
  .width('100%')
  .height(56)
  .padding({ left: 14, right: 14 })
  .backgroundColor(theme.bgPage)
  .alignItems(VerticalAlign.Center)
}

/** 分组底部留白，把分组之间拉开。 */
@Builder
export function TripGroupGap(theme: UniTheme) {
  Column()
    .width('100%')
    .height(12)
    .backgroundColor(theme.bgPage)
}
