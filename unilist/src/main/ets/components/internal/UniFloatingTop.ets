import { UniTheme } from '../theme/UniTheme';

/** 回到顶部的悬浮按钮。滚动距离超过阈值时由容器组件显示。 */
@Component
export struct UniFloatingTop {
  @Prop theme: UniTheme = UniTheme.standard;

  onTap?: () => void;

  build() {
    Column() {
      Text('↑')
        .fontSize(20)
        .fontColor(this.theme.textSecondary)
    }
    .width(44)
    .height(44)
    .borderRadius(22)
    .backgroundColor(this.theme.bgElevated)
    .border({ width: 1, color: this.theme.divider })
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .justifyContent(FlexAlign.Center)
    .margin({ right: 16, bottom: 24 })
    .onClick(() => {
      if (this.onTap !== undefined) {
        this.onTap()
      }
    })
  }
}
