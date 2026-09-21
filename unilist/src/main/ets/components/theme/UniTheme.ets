import { UniRes } from './UniRes';

/**
 * unilist 的视觉主题。
 *
 * 颜色字段默认指向 {@link UniRes} 里的资源引用而非字面量色值——`$r` 会随系统深色模式
 * 自动切换到 `resources/dark` 下的同名资源，所以**默认主题天然支持深色模式**，
 * 调用方不需要为暗色做任何事。
 *
 * 想定制时构造一个实例、覆盖需要的字段，再通过 `theme` 传入即可。颜色字段是
 * `ResourceColor`（`Color | number | string | Resource`），所以既可以给 `'#FF0000'`，
 * 也可以给 `$r('app.color.xxx')`。
 */
export class UniTheme {
  // ---------- 颜色 ----------
  /** 页面底色 */
  bgPage: ResourceColor = UniRes.bgPage;
  /** 卡片底色 */
  bgCard: ResourceColor = UniRes.bgCard;
  /** 浮起元素底色（悬浮按钮、底部提示） */
  bgElevated: ResourceColor = UniRes.bgElevated;
  /** 主文字 */
  textPrimary: ResourceColor = UniRes.textPrimary;
  /** 次要文字 */
  textSecondary: ResourceColor = UniRes.textSecondary;
  /** 三级文字 / 弱提示 */
  textTertiary: ResourceColor = UniRes.textTertiary;
  /** 分割线 */
  divider: ResourceColor = UniRes.divider;
  /** 主题强调色 */
  primary: ResourceColor = UniRes.primary;
  /** 危险色，也是侧滑删除按钮的默认底色 */
  danger: ResourceColor = UniRes.danger;
  /** 骨架屏色块 */
  skeleton: ResourceColor = UniRes.skeleton;

  // ---------- 卡片流规格 ----------
  /** 卡片圆角 */
  cardRadius: number = 12;
  /** 卡片之间的间距，也是 List 的 space */
  cardGap: number = 8;
  /** 内容区左右留白 */
  pagePadding: number = 12;
  /** 内容区底部留白，避免最后一屏被系统手势条遮住 */
  bottomInset: number = 20;
  /** 卡片内边距 */
  cardPadding: number = 12;
  /** 卡片阴影半径 */
  shadowRadius: number = 8;
  /** 卡片阴影颜色（#AARRGGBB） */
  shadowColor: string = '#0F000000';
  /** 卡片阴影 Y 偏移 */
  shadowOffsetY: number = 2;

  // ---------- 行式布局规格 ----------
  /** 缩略图边长 */
  thumbSize: number = 48;
  /** 缩略图圆角 */
  thumbRadius: number = 8;
  /** 主标题字号 */
  fontTitle: number = 16;
  /** 正文字号 */
  fontBody: number = 14;
  /** 辅助文字字号 */
  fontCaption: number = 13;
  /** 底部状态栏高度 */
  footerHeight: number = 48;

  /** 默认主题。 */
  static readonly standard: UniTheme = new UniTheme();
}
