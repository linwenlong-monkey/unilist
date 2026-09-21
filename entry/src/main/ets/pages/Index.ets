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

  @State theme: UniTheme = UniTheme.standard;

  @Provide('uniPathStack') pathStack: NavPathStack = new NavPathStack();

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
