import { UniTheme } from 'unilist';
import { FeedVO } from '../../model/FeedModel';

/**
 * 「现代卡片流」的行内容。
 *
 * 刻意写成**全局 `@Builder` 函数**而不是 `@Component struct`：
 * 在传给 `UniList` 的 `itemBuilder`（即 `@BuilderParam`）内部**实例化自定义组件**
 * 会触发运行期 `class constructor cannot called without 'new'`，
 * 而这里只是画一堆内置组件，用全局 `@Builder` 既够用又绕开了那个坑。
 *
 * 它只负责**卡片内部**长什么样——圆角、底色、阴影、卡片间距由 `UniList` 统一施加。
 * 代价是全局 @Builder 拿不到 `this`，所以所需数据必须全部由参数传进来。
 */
@Builder
export function CardRow(item: FeedVO, theme: UniTheme) {
  Row() {
    // 缩略图占位：用色块 + 首字，避免引入图片资源依赖
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
