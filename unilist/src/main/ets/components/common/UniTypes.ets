/** 列表内容区要展示的状态。 */
export enum UniState {
  /** 由数据量与加载状态自动推导（默认值）。 */
  Auto = 0,
  /** 首屏加载中，展示骨架屏。 */
  Loading = 1,
  /** 无数据。 */
  Empty = 2,
  /** 加载失败。 */
  Error = 3,
  /** 有数据。 */
  Data = 4
}

/**
 * 「加载更多」的状态机。
 *
 * 之所以需要独立于 {@link UniState}：首屏骨架屏和「加载下一页」的底部提示是两件事，
 * 同时发生时（首屏转圈 + 触底转圈）需要分开表达。
 */
export enum UniLoadState {
  /** 空闲，允许触发下一次加载。 */
  Idle = 0,
  /** 加载中，互斥锁。 */
  Loading = 1,
  /** 已经到底，不再触发。 */
  NoMore = 2,
  /** 加载失败，等待用户点击底部重试。 */
  Failed = 3
}

/** 骨架屏形态，决定占位块怎么排。 */
export enum UniSkeletonVariant {
  /** 左图右文的行式骨架，对应列表与分组列表。 */
  List = 0,
  /** 等宽方块骨架，对应网格与瀑布流。 */
  Grid = 1
}

/**
 * 分组数据。
 *
 * `header` 字段名不用 `title` 是为了避免和 `@Prop title` 之类的常见命名撞车，
 * 同时给调用方留出「同一组想渲染更复杂头部」的空间（用 headerBuilder）。
 */
export interface IUniSection {
  /** 分组标题，会传给 headerBuilder；不传则不渲染默认头部。 */
  title?: string;
  /** 分组内数据。 */
  items: Object[];
}

/** 侧滑菜单里的一个按钮。 */
export interface UniSwipeAction {
  /** 唯一标识，用于回调里区分点的是哪个按钮。 */
  key: string;
  /** 按钮文字。 */
  text: string;
  /** 按钮底色，默认取主题的 danger 色。 */
  color?: ResourceColor;
  /** 文字颜色，默认白色。 */
  textColor?: ResourceColor;
  /** 按钮宽度，不传则用组件的 actionWidth。 */
  width?: number;
}

/**
 * 从数据项取稳定唯一 key 的函数。
 *
 * 拖拽排序、LazyForEach 增量更新都依赖 key 的稳定性，这两种场景**必须**提供。
 */
export type UniItemKey = (item: Object, index: number) => string;
