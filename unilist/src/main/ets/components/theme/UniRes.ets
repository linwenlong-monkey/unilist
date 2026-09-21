/**
 * unilist 内置颜色资源。
 *
 * 所有资源名统一以 `uni_` 为前缀：HAR 的资源会和宿主 App 合并进同一张 `app` 资源表，
 * 合并优先级为 `AppScope > 宿主 HAP > HAR`。宿主一旦定义同名的 `app.color`，
 * HAR 的同名资源会被**静默覆盖**（暗色适配随之失效），所以前缀是唯一的防冲突手段。
 *
 * 颜色书写格式为 `#AARRGGBB`（alpha 在前）。
 */
export class UniRes {
  /** 页面底色 */
  static readonly bgPage: Resource = $r('app.color.uni_color_bg_page');
  /** 卡片底色 */
  static readonly bgCard: Resource = $r('app.color.uni_color_bg_card');
  /** 浮起元素底色（悬浮按钮、footer 等） */
  static readonly bgElevated: Resource = $r('app.color.uni_color_bg_elevated');
  /** 主文字 */
  static readonly textPrimary: Resource = $r('app.color.uni_color_text_primary');
  /** 次要文字 */
  static readonly textSecondary: Resource = $r('app.color.uni_color_text_secondary');
  /** 三级文字 / 弱提示 */
  static readonly textTertiary: Resource = $r('app.color.uni_color_text_tertiary');
  /** 分割线 */
  static readonly divider: Resource = $r('app.color.uni_color_divider');
  /** 主题强调色 */
  static readonly primary: Resource = $r('app.color.uni_color_primary');
  /** 危险色（删除、错误） */
  static readonly danger: Resource = $r('app.color.uni_color_danger');
  /** 骨架屏色块 */
  static readonly skeleton: Resource = $r('app.color.uni_color_skeleton');
  /** 按压态叠加色 */
  static readonly pressed: Resource = $r('app.color.uni_color_pressed');
}
