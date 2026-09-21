/**
 * 组件内所有可见文案。
 *
 * 单独抽出来的原因有两个：一是方便整体替换成英文或其它语言，
 * 二是示例里需要「状态画廊」同时展示多种文案而不互相干扰。
 */
export class UniTexts {
  /** 首屏加载中的提示（骨架屏下不显示，仅供自绘场景） */
  loading: string = '加载中...';
  /** 空态主文案 */
  empty: string = '暂无数据';
  /** 空态副文案 */
  emptyHint: string = '下拉可以刷新试试';
  /** 错误态主文案 */
  error: string = '加载失败';
  /** 错误态按钮 */
  retry: string = '重试';
  /** 底部：正在加载下一页 */
  loadingMore: string = '正在加载...';
  /** 底部：已经到底 */
  noMore: string = '没有更多了';
  /** 底部：加载下一页失败 */
  loadMoreFailed: string = '加载失败，点击重试';

  static readonly standard: UniTexts = new UniTexts();
}
