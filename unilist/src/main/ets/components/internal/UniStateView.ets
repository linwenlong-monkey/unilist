import { UniSkeletonVariant, UniState } from '../common/UniTypes';
import { UniTheme } from '../theme/UniTheme';
import { UniTexts } from '../theme/UniTexts';
import { UniSkeleton } from './UniSkeleton';

/**
 * 三态视图的**默认**渲染：加载中 / 空 / 出错。
 *
 * 这是消除「五个组件复制五份」的关键——以前 `UniList`、`UniGrid`、`UniWaterfall`
 * 各自内联了一份几乎相同的 if/else 三态骨架，现在全部收敛到这里。
 *
 * 注意本组件**刻意只接收标量属性**，不接受 `@BuilderParam`。原因是 ArkTS 不允许
 * 把一个组件的 `@BuilderParam` 透传给另一个组件（会报 "can only be initialized by
 * '@Builder' function"）。所以「调用方自定义三态」的派发放在各个容器组件的
 * `stateArea()` 里，本组件只负责兜底的默认样式。
 */
@Component
export struct UniStateView {
  @Prop state: UniState = UniState.Empty;
  @Prop theme: UniTheme = UniTheme.standard;
  @Prop texts: UniTexts = UniTexts.standard;
  /** 错误态展示的具体信息，为空则用 texts.error */
  @Prop errorMessage: string = '';
  /** 骨架屏形态 */
  @Prop skeletonVariant: UniSkeletonVariant = UniSkeletonVariant.List;
  /** 骨架屏列数（网格形态用） */
  @Prop skeletonColumns: number = 2;

  /** 出错态点击重试 */
  onRetry?: () => void;

  @Builder
  skeleton(): void {
    UniSkeleton({
      variant: this.skeletonVariant,
      theme: this.theme,
      columns: this.skeletonColumns
    })
  }

  @Builder
  empty(): void {
    Column() {
      // 空态用几何图形占位，避免给组件库引入图片资源依赖
      Column()
        .width(72)
        .height(56)
        .borderRadius(8)
        .border({ width: 2, color: this.theme.divider })
      Text(this.texts.empty)
        .fontSize(this.theme.fontTitle)
        .fontColor(this.theme.textSecondary)
        .margin({ top: 16 })
      Text(this.texts.emptyHint)
        .fontSize(this.theme.fontCaption)
        .fontColor(this.theme.textTertiary)
        .margin({ top: 6 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  error(): void {
    Column() {
      Text(this.errorMessage.length > 0 ? this.errorMessage : this.texts.error)
        .fontSize(this.theme.fontBody)
        .fontColor(this.theme.textSecondary)
      Button(this.texts.retry)
        .fontSize(this.theme.fontBody)
        .fontColor(Color.White)
        .backgroundColor(this.theme.primary)
        .borderRadius(20)
        .height(40)
        .padding({ left: 24, right: 24 })
        .margin({ top: 16 })
        .onClick(() => {
          if (this.onRetry !== undefined) {
            this.onRetry()
          }
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Column() {
      if (this.state === UniState.Loading) {
        this.skeleton()
      } else if (this.state === UniState.Error) {
        this.error()
      } else {
        this.empty()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.bgPage)
  }
}
