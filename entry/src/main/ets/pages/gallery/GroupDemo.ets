import { IUniSection, UniGroupList, UniTheme, UniTexts } from 'unilist';
import { FeedVO, makeSections, SectionData } from '../../model/FeedModel';

/** 分组演示：吸顶 / 折叠 / 索引条三个开关可切换。 */
@Component
export struct GroupDemo {
  @Prop theme: UniTheme = UniTheme.standard;
  @Consume('uniPathStack') pathStack: NavPathStack;

  @State sections: IUniSection[] = [];
  @State sticky: boolean = true;
  @State collapsible: boolean = true;
  @State showIndexer: boolean = true;
  @State tip: string = '';

  aboutToAppear(): void {
    this.sections = this.buildSections();
  }

  private buildSections(): IUniSection[] {
    const raw: SectionData[] = makeSections(2);
    const out: IUniSection[] = [];
    for (let i = 0; i < raw.length; i++) {
      out.push({ title: raw[i].title, items: raw[i].items });
    }
    return out;
  }

  @Builder
  switchRow(label: string, value: boolean, onToggle: (on: boolean) => void): void {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor(this.theme.textPrimary)
        .layoutWeight(1)
      Toggle({ type: ToggleType.Switch, isOn: value })
        .onChange((on: boolean) => {
          onToggle(on);
        })
    }
    .width('100%')
    .padding({ left: 12, right: 12 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  row(item: Object, sectionIndex: number, itemIndex: number): void {
    Row() {
      Column() {
        Text((item as FeedVO).title)
          .fontSize(15)
          .fontColor(this.theme.textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text((item as FeedVO).subtitle)
          .fontSize(12)
          .fontColor(this.theme.textSecondary)
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .padding({ top: 12, bottom: 12 })
      Text((item as FeedVO).tail)
        .fontSize(14)
        .fontColor(this.theme.primary)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        this.switchRow('吸顶', this.sticky, (on: boolean) => { this.sticky = on })
        this.switchRow('可折叠', this.collapsible, (on: boolean) => { this.collapsible = on })
        this.switchRow('索引条', this.showIndexer, (on: boolean) => { this.showIndexer = on })
        if (this.tip.length > 0) {
          Text(this.tip)
            .fontSize(12)
            .fontColor(this.theme.textSecondary)
            .width('100%')
            .padding({ left: 12, top: 4, bottom: 4 })
        }

        UniGroupList({
          sections: this.sections,
          theme: this.theme,
          texts: UniTexts.standard,
          sticky: this.sticky,
          collapsible: this.collapsible,
          showIndexer: this.showIndexer,
          divider: true,
          enableRefresh: true,
          onRefresh: () => {
            return new Promise<void>((resolve) => {
              setTimeout(() => {
                this.sections = this.buildSections();
                resolve();
              }, 800);
            });
          },
          onItemClick: (item: Object, s: number, i: number) => {
            this.tip = `点了「${(item as FeedVO).title}」（第 ${s + 1} 组第 ${i + 1} 项）`;
          },
          onCollapseChange: (s: number, collapsed: boolean) => {
            this.tip = `${collapsed ? '折叠' : '展开'}了第 ${s + 1} 组`;
          },
          // ⚠️ 箭头函数包裹
          itemBuilder: (item: Object, sectionIndex: number, itemIndex: number) => {
            this.row(item, sectionIndex, itemIndex)
          }
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.theme.bgPage)
    }
    .title('分组 UniGroupList')
    .onBackPressed(() => {
      this.pathStack.pop();
      return true;
    })
  }
}
