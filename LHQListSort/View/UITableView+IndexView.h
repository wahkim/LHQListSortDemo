//
//  UITableView+IndexView.h
//  LHQListSort
//
//  Created by Xhorse_iOS3 on 2021/1/16.
//

#import <UIKit/UIKit.h>
#import "IndexViewConfiguration.h"

@protocol TableViewSectionIndexDelegate

/**
 当点击或者滑动索引视图时，回调这个方法
 
 @param tableView 列表视图
 @param section   索引位置
 */
- (void)tableView:(UITableView *)tableView didSelectIndexViewAtSection:(NSUInteger)section;

/**
 当滑动tableView时，索引位置改变，你需要自己返回索引位置时，实现此方法。
 不实现此方法，或者方法的返回值为 IndexViewInvalidSection 时，索引位置将由控件内部自己计算。
 
 @param tableView 列表视图
 @return          索引位置
 */
- (NSUInteger)sectionOfTableViewDidScroll:(UITableView *)tableView;

@end

@interface UITableView (IndexView)

@property (nonatomic, weak) id<TableViewSectionIndexDelegate> indexViewDelegate;

// 索引视图数据源
@property (nonatomic, copy) NSArray<NSString *> *indexViewDataSource;

// tableView在NavigationBar上是否半透明
@property (nonatomic, assign) BOOL translucentForTableViewInNavigationBar;

// tableView从第几个section开始使用索引 Default = 0
@property (nonatomic, assign) NSUInteger startSection;

// 索引视图的配置
@property (nonatomic, strong) IndexViewConfiguration *indexViewConfiguration;

// 手动更新IndexView的CurrentSection
- (void)_refreshCurrentSectionOfIndexView;

@end


