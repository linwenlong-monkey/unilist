import { UniSwipeAction } from './common/UniTypes';
import { UniTheme } from './theme/UniTheme';

/** 单个侧滑按钮的回调签名。 */
export type UniSwipeActionHandler = (action: UniSwipeAction, index: number) => void;

/**
 * 侧滑菜单项。
 *
 * 使用方式有两种：
 *
 * 1. **独立使用**——直接放进 `List` 的 `ForEach` 里。它自己会产出 `ListItem`，
 *    调用方**不需要**再手写 `ListItem` 包裹。
 * 2. **交给 `UniList` 托管**——`UniList({ enableSwipe: true, swipeActions: ... })`，
 *    由容器自动为每一行套上本组件。
 *
 * 关于「一次只滑开一个」：API 20 基线下**做不到**。关闭指定 item 的侧滑需要
 * `ListItemSwipeActionManager`（API 21 起），而 `ListScroller.closeAllSwipeActions()`
 * 会连当前正在操作的那个一起收起。因此这里实现的是可用的降级方案：
 * 列表开始滚动时自动收起已展开的侧滑菜单（见 `UniList` 的 `onScrollStart`），
 * 点按钮后也会立即收起自己。
 */
@Component
export struct UniSwipeItem {
  /** 右侧按钮，按数组顺序从右往左排（数组第一项最靠右）。 */
  @Prop actions: UniSwipeAction[] = [];
  @Prop theme: UniTheme = UniTheme.standard;
  /** 按钮默认宽度，单个按钮可用 `UniSwipeAction.width` 覆盖。 */
  @Prop actionWidth: number = 76;
  /** 松手后按钮区是否回弹 */
  @Prop swipeEdgeEffect: SwipeEdgeEffect = SwipeEdgeEffect.Spring;
  /**
   * 滑动多少距离后按钮区保持展开（松手不回弹）。
   *
   * 实测：不设这个值（或设得比按钮总宽还大）时，松手后按钮区会直接弹回去，
   * 侧滑菜单根本留不住。默认取「所有按钮宽度之和」，保证滑开就是全展开。
   */
  @Prop actionAreaDistance: number = 0;

  /** 点击某个按钮 */
  onAction?: UniSwipeActionHandler;
  /** 侧滑展开状态变化，用于调用方感知当前展开的是哪一项 */
  onSwipeStateChange?: (state: SwipeActionState) => void;

  @BuilderParam contentBuilder: () => void;

  /** 按钮区总宽度；`actionAreaDistance` 为 0 时用它作为滑开阈值。 */
  private totalActionWidth(): number {
    if (this.actions.length === 0) {
      return this.actionWidth;
    }
    let w = 0;
    for (let i = 0; i < this.actions.length; i++) {
      w += this.actions[i].width !== undefined ? this.actions[i].width! : this.actionWidth;
    }
    return w;
  }

  @Builder
  actionButtons(): void {
    Row() {
      ForEach(this.actions, (action: UniSwipeAction, index: number) => {
        Column() {
          Text(action.text)
            .fontSize(14)
            .fontColor(action.textColor !== undefined ? action.textColor : Color.White)
            .fontWeight(FontWeight.Medium)
        }
        .width(action.width !== undefined ? action.width : this.actionWidth)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(action.color !== undefined ? action.color : this.theme.danger)
        .onClick(() => {
          if (this.onAction !== undefined) {
            this.onAction(action, index)
          }
        })
      }, (action: UniSwipeAction, index: number) => action.key)
    }
    .height('100%')
  }

  build() {
    ListItem() {
      this.contentBuilder()
    }
    .swipeAction({
      end: {
        // ⚠️ 必须用箭头函数包裹，直接传 `this.actionButtons` 会丢失 this 绑定
        builder: () => {
          this.actionButtons()
        },
        actionAreaDistance: this.actionAreaDistance > 0
          ? this.actionAreaDistance
          : this.totalActionWidth(),
        onStateChange: (state: SwipeActionState) => {
          if (this.onSwipeStateChange !== undefined) {
            this.onSwipeStateChange(state)
          }
        }
      },
      edgeEffect: this.swipeEdgeEffect
    })
  }
}
