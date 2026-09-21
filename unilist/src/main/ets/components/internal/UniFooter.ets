import { UniLoadState } from '../common/UniTypes';
import { UniTheme } from '../theme/UniTheme';
import { UniTexts } from '../theme/UniTexts';

/**
 * 列表底部的状态提示。
 *
 * 四种状态：空闲（不占位）/ 加载中 / 没有更多 / 加载失败可点击重试。
 * 只负责展示与把点击转出去，状态本身由容器组件持有。
 */
@Component
export struct UniFooter {
  @Prop loadState: UniLoadState = UniLoadState.Idle;
  @Prop theme: UniTheme = UniTheme.standard;
  @Prop texts: UniTexts = UniTexts.standard;

  /** 加载失败时点击重试 */
  onRetry?: () => void;

  build() {
    Row() {
      if (this.loadState === UniLoadState.Loading) {
        LoadingProgress()
          .width(20)
          .height(20)
          .color(this.theme.primary)
        Text(this.texts.loadingMore)
          .fontSize(this.theme.fontCaption)
          .fontColor(this.theme.textTertiary)
          .margin({ left: 8 })
      } else if (this.loadState === UniLoadState.NoMore) {
        // 两侧短线夹一个文案，比纯文字更像"到底了"
        Divider()
          .width(28)
          .color(this.theme.divider)
          .strokeWidth(1)
        Text(this.texts.noMore)
          .fontSize(this.theme.fontCaption)
          .fontColor(this.theme.textTertiary)
          .margin({ left: 10, right: 10 })
        Divider()
          .width(28)
          .color(this.theme.divider)
          .strokeWidth(1)
      } else if (this.loadState === UniLoadState.Failed) {
        Text(this.texts.loadMoreFailed)
          .fontSize(this.theme.fontCaption)
          .fontColor(this.theme.primary)
          .onClick(() => {
            if (this.onRetry !== undefined) {
              this.onRetry()
            }
          })
      }
    }
    .width('100%')
    .height(this.loadState === UniLoadState.Idle ? 0 : this.theme.footerHeight)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }
}
