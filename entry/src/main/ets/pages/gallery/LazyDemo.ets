import { UniItemKey, UniList, UniTheme, UniTexts } from 'unilist';
import { FeedVO, makeFeed } from '../../model/FeedModel';
import { CardRow } from './CardRow';

/**
 * `IDataSource` 的最小实现。
 *
 * `LazyForEach` 会自己调用 `registerDataChangeListener` 订阅变化，所以数据源
 * **不需要**任何状态装饰器——这也是 `UniList.dataSource` 刻意不标 `@Prop` 的原因。
 */
class FeedDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private data: FeedVO[] = [];

  constructor(data: FeedVO[]) {
    this.data = data;
  }

  totalCount(): number {
    return this.data.length;
  }

  getData(index: number): Object {
    return this.data[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const i = this.listeners.indexOf(listener);
    if (i >= 0) {
      this.listeners.splice(i, 1);
    }
  }

  /** 追加一批数据，只通知新增的那一段，不重建整个列表。 */
  append(more: FeedVO[]): void {
    const start = this.data.length;
    this.data = this.data.concat(more);
    for (let i = 0; i < this.listeners.length; i++) {
      this.listeners[i].onDataAdd(start);
    }
  }

  /** 从头部插入一批。 */
  prependAt(more: FeedVO[]): void {
    this.data = more.concat(this.data);
    for (let i = 0; i < this.listeners.length; i++) {
      this.listeners[i].onDataAdd(0);
    }
  }

  clear(): void {
    this.data = [];
    for (let i = 0; i < this.listeners.length; i++) {
      this.listeners[i].onDataReloaded();
    }
  }
}

/**
 * 大数据量演示：2000 条数据走 `LazyForEach`，只渲染视口内的行。
 *
 * 同时演示**增量通知**——「头部插入」只触发 `onDataAdd`，不会重建整个列表，
 * 这是普通数组（`items` 路径）做不到的。
 */
@Component
export struct LazyDemo {
  @Prop theme: UniTheme = UniTheme.standard;
  @Consume('uniPathStack') pathStack: NavPathStack;

  @State count: number = 2000;
  @State tip: string = '';
  private dataSource: FeedDataSource = new FeedDataSource([]);
  private seed: number = 0;

  aboutToAppear(): void {
    this.dataSource = new FeedDataSource(makeFeed(this.count, this.seed, 0));
  }

  private keyOf: UniItemKey = (item: Object, index: number) => (item as FeedVO).id;

  /**
   * ⚠️ 必须经由 `@Builder` 方法再调全局 `@Builder`（CardRow）。
   * 直接在传出去的箭头函数体里写 `CardRow(...)` 会抛
   * `Cannot read property observeComponentCreation2 of undefined`。
   */
  @Builder
  cardRow(item: Object, index: number): void {
    CardRow(item as FeedVO, this.theme)
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text(`${this.count} 条`)
            .fontSize(13)
            .fontColor(this.theme.textSecondary)
            .layoutWeight(1)
          Text('头部插入 20 条')
            .fontSize(13)
            .fontColor(this.theme.primary)
            .margin({ right: 16 })
            .onClick(() => {
              this.seed -= 20;
              this.dataSource.prependAt(makeFeed(20, this.seed, 0));
              this.count += 20;
              this.tip = '只通知了 onDataAdd，没有重建列表';
            })
          Text('追加 20 条')
            .fontSize(13)
            .fontColor(this.theme.primary)
            .onClick(() => {
              this.dataSource.append(makeFeed(20, this.seed, this.count));
              this.count += 20;
              this.tip = '追加了 20 条';
            })
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .alignItems(VerticalAlign.Center)

        if (this.tip.length > 0) {
          Text(this.tip)
            .fontSize(12)
            .fontColor(this.theme.textTertiary)
            .width('100%')
            .padding({ left: 12, bottom: 6 })
        }

        UniList({
          // dataSource 优先级高于 items，走 LazyForEach
          dataSource: this.dataSource,
          theme: this.theme,
          texts: UniTexts.standard,
          itemKey: this.keyOf,
          enableRefresh: false,
          enableLoadMore: false,
          enableFloatingTop: true,
          itemBuilder: (item: Object, index: number) => {
            this.cardRow(item, index)
          }
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.theme.bgPage)
    }
    .title('大数据量 LazyForEach')
    .onBackPressed(() => {
      this.pathStack.pop();
      return true;
    })
  }
}
