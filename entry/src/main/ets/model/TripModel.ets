/**
 * 旅行实战页的数据模型。
 *
 * 图片走 `$r('app.media.imgN')` —— 资源是打包期解析的，**必须写成字面量**，
 * 不能拼字符串，所以这里用数组下标直接取。
 */

/** 一张已打包的风景图。 */
export class TripPhoto {
  /** 资源引用 */
  res: Resource;
  /** 无障碍描述 / 图片说明 */
  caption: string;

  constructor(res: Resource, caption: string) {
    this.res = res;
    this.caption = caption;
  }
}

/** 8 张内置风景图。 */
export const PHOTOS: TripPhoto[] = [
  new TripPhoto($r('app.media.img1'), '雪山湖泊'),
  new TripPhoto($r('app.media.img2'), '森林小径'),
  new TripPhoto($r('app.media.img3'), '秋日公路'),
  new TripPhoto($r('app.media.img4'), '城市公园'),
  new TripPhoto($r('app.media.img5'), '草原晨雾'),
  new TripPhoto($r('app.media.img6'), '冰川湖泊'),
  new TripPhoto($r('app.media.img7'), '沙漠驼铃'),
  new TripPhoto($r('app.media.img8'), '热带海滩')
];

/** 一个目的地。 */
export class TripVO {
  id: string;
  /** 目的地名 */
  name: string;
  /** 一句话卖点 */
  tagline: string;
  /** 行程天数 */
  days: number;
  /** 评分 */
  rating: number;
  /** 起步价 */
  price: number;
  /** 卡片图下标 */
  photo: number;
  /** 详情页轮播图的图下标集合 */
  gallery: number[];
  /** 详情页的行程亮点 */
  highlights: string[];

  constructor(id: string, name: string, tagline: string, days: number, rating: number,
              price: number, photo: number, gallery: number[], highlights: string[]) {
    this.id = id;
    this.name = name;
    this.tagline = tagline;
    this.days = days;
    this.rating = rating;
    this.price = price;
    this.photo = photo;
    this.gallery = gallery;
    this.highlights = highlights;
  }
}

/** 一个地区分组。 */
export class TripSection {
  title: string;
  subtitle: string;
  trips: TripVO[];

  constructor(title: string, subtitle: string, trips: TripVO[]) {
    this.title = title;
    this.subtitle = subtitle;
    this.trips = trips;
  }
}

/** 首页头部那张大图。 */
export const HERO_PHOTO: number = 0;

/** 「精选推荐」里的图下标。 */
export const PICK_PHOTOS: number[] = [1, 2, 3, 4];

/** 所有分组。 */
export function makeSections(): TripSection[] {
  return [
    new TripSection('亚洲', '东方的四季与人情', [
      new TripVO('jp-kyoto', '京都 · 赏枫', '古寺红叶，一步一景', 5, 4.8, 3280, 2,
        [2, 3, 4], ['奈良喂鹿', '岚山竹林小火车', '清水寺夜枫点灯', '和服体验漫步祇园']),
      new TripVO('id-bali', '巴厘岛 · 海岛', '碧海白沙滩，慢下来的假期', 7, 4.7, 4560, 7,
        [7, 4, 5], ['乌布梯田看日出', '海神庙落日', '浮潜看珊瑚礁', '丛林秋千']),
      new TripVO('cn-inner', '呼伦贝尔 · 草原', '草浪与晨雾，天地一线', 6, 4.6, 2680, 4,
        [4, 1, 6], ['莫日格勒河', '草原骑马', '看日出晨雾', '牧民家访'])
    ]),
    new TripSection('欧洲', '阿尔卑斯的两副面孔', [
      new TripVO('ch-alps', '阿尔卑斯 · 徒步', '雪山倒映在湖里', 6, 4.9, 6380, 0,
        [0, 5, 1], ['少女峰观景台', '高山湖泊徒步', '冰川快车', '雪山日落']),
      new TripVO('no-fjord', '挪威 · 冰川湖', '蓝绿色湖水托着雪峰', 8, 4.8, 7920, 5,
        [5, 0, 6], ['布道石徒步', '峡湾游船', '冰川徒步', '极光追猎'])
    ]),
    new TripSection('非洲 · 大洋洲', '另一种辽阔', [
      new TripVO('ma-sahara', '撒哈拉 · 沙漠', '沙丘的曲线与光影', 5, 4.5, 3980, 6,
        [6, 3, 7], ['骑骆驼进沙丘', '沙漠露营看星', '柏柏尔人家访', '沙丘日落'])
    ])
  ];
}

/** 拼一个「N 天 M 晚」的行程文案。 */
export function tripMeta(t: TripVO): string {
  return `${t.days} 天 ${t.days - 1} 晚`;
}
