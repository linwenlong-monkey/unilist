import { UniTheme } from 'unilist';
import { FeedVO } from '../../model/FeedModel';

@Builder
export function CardRow(item: FeedVO, theme: UniTheme) {
  Row() {
    Column() {
      Text(item.title.substring(0, 1))
        .fontSize(20)
        .fontColor(Color.White)
    }
    .width(theme.thumbSize)
    .height(theme.thumbSize)
    .borderRadius(theme.thumbRadius)
    .backgroundColor(item.color)
    .justifyContent(FlexAlign.Center)

    Column() {
      Text(item.title)
        .fontSize(theme.fontTitle)
        .fontColor(theme.textPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(item.subtitle)
        .fontSize(theme.fontCaption)
        .fontColor(theme.textSecondary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
    .margin({ left: 12 })

    Text(item.tail)
      .fontSize(theme.fontBody)
      .fontWeight(FontWeight.Medium)
      .fontColor(theme.primary)
  }
  .width('100%')
  .padding(theme.cardPadding)
  .alignItems(VerticalAlign.Center)
}
