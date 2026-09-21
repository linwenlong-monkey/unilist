import { UniTheme } from 'unilist';
import { GalleryHome } from './gallery/GalleryHome';
import { ListDemo } from './gallery/ListDemo';
import { StateDemo } from './gallery/StateDemo';
import { GridDemo } from './gallery/GridDemo';
import { WaterfallDemo } from './gallery/WaterfallDemo';
import { GroupDemo } from './gallery/GroupDemo';
import { SwipeDemo } from './gallery/SwipeDemo';
import { LazyDemo } from './gallery/LazyDemo';
import { FeedPage } from './real/FeedPage';
import { TripDetailPage } from './real/TripDetailPage';
import { TripVO } from '../model/TripModel';

@Entry
@Component
struct Index {
  /**
   * 全应用共用的主题。
   *
   * 放在最外层持有，各演示页通过 `@Prop theme` 接过去——`UniTheme` 全是基础类型字段，
   * `@Prop` 的深拷贝成本可以忽略，而一旦改这里，所有页面会一起换肤。
   */
  @State theme: UniTheme = UniTheme.standard;
  /**
   * 全应用共用的导航栈。
   *
   * `@Provide` 出去、各页面 `@Consume` 进来，而不是当 `@Prop` 往下传——
   * `NavPathStack` 是普通对象，`@Prop` 会给每个页面各造一份副本，
   * 子页面拿副本调 `pushPath` 会直接触发 ArkUI 原生侧空指针崩溃（SIGSEGV）。
   */
  @Provide('uniPathStack') pathStack: NavPathStack = new NavPathStack();

  /**
   * 导航目的地分发。
   *
   * ⚠️ `navDestination` **只能注册一个 builder**，注册第二个会把第一个覆盖掉，
   * 被覆盖的那些路由会静默渲染成空节点（日志：`can't find target destination by index,
   * create empty node`）。所以所有目的地都必须在这一个里分发。
   *
   * 第二个参数写 `param: object` 而不是 `unknown`——ArkTS 禁用 `unknown`，
   * 而 `object` 既能接住 `pushPath` 传的 `Record`，也允许 `as` 成具体类型。
   */
  @Builder
  pageMap(name: string, param: object) {
    if (name === 'tripDetail') {
      TripDetailPage({ theme: this.theme, trip: param as TripVO })
    } else if (name === 'list') {
      ListDemo({ theme: this.theme })
    } else if (name === 'states') {
      StateDemo({ theme: this.theme })
    } else if (name === 'grid') {
      GridDemo({ theme: this.theme })
    } else if (name === 'waterfall') {
      WaterfallDemo({ theme: this.theme })
    } else if (name === 'group') {
      GroupDemo({ theme: this.theme })
    } else if (name === 'swipe') {
      SwipeDemo({ theme: this.theme })
    } else if (name === 'lazy') {
      LazyDemo({ theme: this.theme })
    } else if (name === 'feed') {
      FeedPage({ theme: this.theme })
    }
  }


  build() {
    Navigation(this.pathStack) {
      GalleryHome({ theme: this.theme })
    }
    .navDestination(this.pageMap)
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.bgPage)
  }
}
