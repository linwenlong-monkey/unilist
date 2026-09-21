import { UniSkeletonVariant } from '../common/UniTypes';
import { UniTheme } from '../theme/UniTheme';

/**
 * 骨架屏占位块。
 *
 * 用 `@Reusable` 是因为骨架屏通常一次渲染十几到几十个、且会随滚动反复进出视口，
 * 复用能省掉重复的构建开销。（`@Reusable` 的带参形式是 API 26，基线上只能用无参。）
 */
@Component
@Reusable
export struct UniSkeletonBar {
  @Prop theme: UniTheme = UniTheme.standard;
  @Prop barWidth: number = 120;
  @Prop barHeight: number = 14;

  build() {
    Column()
      .width(this.barWidth)
      .height(this.barHeight)
      .borderRadius(this.barHeight / 2)
      .backgroundColor(this.theme.skeleton)
  }
}

/**
 * 骨架屏内容。
 *
 * `variant` 决定形态：列表是「左图右两行文」，网格是等宽方块阵列。
 * 默认用 `@BuilderParam` 覆盖单个格子的样式，不传就走内置样式。
 */
@Component
export struct UniSkeleton {
  @Prop variant: UniSkeletonVariant = UniSkeletonVariant.List;
  @Prop theme: UniTheme = UniTheme.standard;
  /** 列表形态的条数 */
  @Prop count: number = 8;
  /** 网格形态的列数 */
  @Prop columns: number = 2;

  @Builder
  listRow(): void {
    Row() {
      Column()
        .width(this.theme.thumbSize)
        .height(this.theme.thumbSize)
        .borderRadius(this.theme.thumbRadius)
        .backgroundColor(this.theme.skeleton)
      Column() {
        UniSkeletonBar({ theme: this.theme, barWidth: 140, barHeight: 15 })
        UniSkeletonBar({ theme: this.theme, barWidth: 90, barHeight: 13 })
          .margin({ top: 10 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })
    }
    .width('100%')
    .padding(this.theme.cardPadding)
    .borderRadius(this.theme.cardRadius)
    .backgroundColor(this.theme.bgCard)
    .margin({ bottom: this.theme.cardGap })
  }

  @Builder
  gridCell(): void {
    Column()
      .width('100%')
      .height(120)
      .borderRadius(this.theme.cardRadius)
      .backgroundColor(this.theme.bgCard)
  }

  build() {
    if (this.variant === UniSkeletonVariant.List) {
      Column() {
        ForEach(Array.from({ length: this.count }, (_: undefined, i: number) => i),
          (_: number) => {
            this.listRow()
          }, (i: number) => i.toString())
      }
      .width('100%')
      .padding({ left: this.theme.pagePadding, right: this.theme.pagePadding, top: this.theme.pagePadding })
      .alignItems(HorizontalAlign.Start)
    } else {
      Grid() {
        ForEach(Array.from({ length: this.count }, (_: undefined, i: number) => i),
          (_: number) => {
            GridItem() {
              this.gridCell()
            }
          }, (i: number) => i.toString())
      }
      .columnsTemplate(`repeat(${this.columns}, 1fr)`)
      .columnsGap(this.theme.cardGap)
      .rowsGap(this.theme.cardGap)
      .padding(this.theme.pagePadding)
      .width('100%')
      .layoutWeight(1)
    }
  }
}
