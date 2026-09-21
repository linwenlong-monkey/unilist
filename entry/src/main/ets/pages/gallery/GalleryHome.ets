import { UniTheme } from 'unilist';
import { FeedVO, makeFeed } from '../../model/FeedModel';

/** 画廊条目。 */
class GalleryEntry {
  title: string;
  desc: string;
  route: string;

  constructor(title: string, desc: string, route: string) {
    this.title = title;
    this.desc = desc;
    this.route = route;
  }
}

/**
 * 组件画廊首页。
 *
 * 用一个**自己搭的朴素列表**（而非 `UniList`）来放导航项——这样即使 `UniList`
 * 本身出问题，也还能进到各个演示页去定位，不会把自己锁死。
 */
@Component
export struct GalleryHome {
  @Prop theme: UniTheme = UniTheme.standard;
  /** 来自外层 `Navigation` 的栈，用 `@Consume` 取到同一个实例 */
  @Consume('uniPathStack') pathStack: NavPathStack;

  private entries: GalleryEntry[] = [
    new GalleryEntry('列表 UniList', '刷新 / 触底加载 / 三种空态 / 拖拽 / 侧滑', 'list'),
    new GalleryEntry('状态画廊', '手动切换 加载中 / 空 / 错误 / 没有更多', 'states'),
    new GalleryEntry('网格 UniGrid', '列数 1~4 实时切换', 'grid'),
    new GalleryEntry('瀑布流 UniWaterfall', '不等高卡片，错落排列', 'waterfall'),
    new GalleryEntry('分组 UniGroupList', '吸顶 / 折叠 / 索引条', 'group'),
    new GalleryEntry('侧滑 UniSwipeItem', '多按钮 / 自定义宽度 / 点击回调', 'swipe'),
    new GalleryEntry('大数据量 LazyForEach', '2000 条，增量插入', 'lazy'),
    new GalleryEntry('实战页 Feed', '真实的卡片流页面', 'feed')
  ];

  build() {
    Column() {
      Text('unilist')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.theme.textPrimary)
        .width('100%')
        .padding({ left: 16, top: 8, bottom: 4 })
      Text('面向 HarmonyOS 的列表组件库')
        .fontSize(13)
        .fontColor(this.theme.textSecondary)
        .width('100%')
        .padding({ left: 16, bottom: 12 })

      List({ space: 8 }) {
        ForEach(this.entries, (e: GalleryEntry) => {
          ListItem() {
            Row() {
              Column() {
                Text(e.title)
                  .fontSize(16)
                  .fontColor(this.theme.textPrimary)
                Text(e.desc)
                  .fontSize(13)
                  .fontColor(this.theme.textSecondary)
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              Text('›')
                .fontSize(22)
                .fontColor(this.theme.textTertiary)
            }
            .width('100%')
            .padding(14)
            .borderRadius(this.theme.cardRadius)
            .backgroundColor(this.theme.bgCard)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              this.pathStack.pushPath({ name: e.route })
            })
          }
        }, (e: GalleryEntry) => e.route)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .padding({ left: 12, right: 12, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.bgPage)
  }
}
