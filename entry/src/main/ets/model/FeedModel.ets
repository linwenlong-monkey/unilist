/** 实战页与画廊页共用的数据模型。 */

export class FeedVO {
  id: string;
  title: string;
  subtitle: string;
  tail: string;
  /** 缩略图占位色（示例不引入图片资源，用色块代替） */
  color: string;
  /** 瀑布流卡片高度 */
  height: number;

  constructor(id: string, title: string, subtitle: string, tail: string, color: string, height: number) {
    this.id = id;
    this.title = title;
    this.subtitle = subtitle;
    this.tail = tail;
    this.color = color;
    this.height = height;
  }
}

const COLORS: string[] = [
  '#007DFF', '#FF9500', '#34C759', '#AF52DE',
  '#FF3B30', '#5AC8FA', '#FFCC00', '#FF2D55'
];

const FRUITS: string[] = ['苹果', '香蕉', '橙子', '葡萄', '西瓜', '草莓', '芒果', '蓝莓', '柠檬', '樱桃'];
const TITLES: string[] = [
  '新鲜直达', '冷链直供', '产地现摘', '限时特惠', '今日推荐',
  '会员专享', '买二送一', '当季热销', '爆款返场', '新品上架'
];

/** 造一批数据。`seed` 不同则内容不同，便于刷新后肉眼看出变化。 */
export function makeFeed(count: number, seed: number, startIndex: number = 0): FeedVO[] {
  const out: FeedVO[] = [];
  for (let i = 0; i < count; i++) {
    const n = startIndex + i;
    const s = seed + n;
    out.push(new FeedVO(
      `f${n}`,
      `${FRUITS[s % FRUITS.length]} · ${TITLES[s % TITLES.length]}`,
      `第 ${n + 1} 件 · 已售 ${(s * 37) % 900 + 100}`,
      `¥${(s % 40) + 6}.${(s * 7) % 10}`,
      COLORS[s % COLORS.length],
      // 瀑布流卡片高度：让同一列有长有短，才能看出错落
      130 + (s * 53) % 130
    ));
  }
  return out;
}

/** 分组示例数据。 */
export class SectionData {
  title: string = '';
  items: FeedVO[] = [];
}

export function makeSections(seed: number): SectionData[] {
  const titles: string[] = ['热带水果', '浆果类', '柑橘类', '瓜果类', '核果类'];
  const out: SectionData[] = [];
  let n = 0;
  for (let s = 0; s < titles.length; s++) {
    const sec = new SectionData();
    sec.title = titles[s];
    sec.items = makeFeed(4 + s % 3, seed, n);
    n += sec.items.length;
    out.push(sec);
  }
  return out;
}
