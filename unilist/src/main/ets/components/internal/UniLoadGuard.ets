/** `onReachEnd` 在 edgeEffect 为 Spring 时，越界和回弹到底各触发一次，靠这个窗口去重。 */
const REACH_END_DEBOUNCE_MS: number = 300;

/**
 * 触底加载的去重闸门。
 *
 * 只负责「时间维度」的去重，不持有状态机——状态机（{@link UniLoadState}）放在各个
 * 容器组件自己的 `@State` 里，才能驱动 UI 刷新。这样这个类是个纯逻辑对象，
 * 可以被四个容器组件共享，而不是复制四份。
 */
export class UniLoadGuard {
  private lastTriggerAt: number = 0;

  /**
   * 判断此刻是否允许触发一次加载。
   *
   * @param force 为 true 时跳过防抖窗口。footer 的「点击重试」需要它：
   *              重试往往紧接着上一次失败（窗口内），不跳过就会被自己的防抖挡住。
   */
  canTrigger(force: boolean): boolean {
    const now: number = Date.now();
    if (!force && now - this.lastTriggerAt < REACH_END_DEBOUNCE_MS) {
      return false;
    }
    this.lastTriggerAt = now;
    return true;
  }
}
