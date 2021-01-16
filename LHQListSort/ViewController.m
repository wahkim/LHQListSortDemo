//
//  ViewController.m
//  LHQListSort
//
//  Created by Xhorse_iOS3 on 2021/1/15.
//

#import "ViewController.h"
#import "IndexListSort.h"
#import "CarLineModel.h"
#import "MJExtension.h"
#import "IndexHeaderView.h"
#import "IndexViewConfiguration.h"
#import "UITableView+IndexView.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property(nonatomic,strong)NSMutableArray *firstLetterArray;
@property(nonatomic,strong)NSMutableArray<NSMutableArray *> *sortedModelArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [self.tableView registerClass:[IndexHeaderView class] forHeaderFooterViewReuseIdentifier:IndexHeaderView.reuseIdentifier];
    
    IndexViewConfiguration *configuration = [IndexViewConfiguration configuration];
    self.tableView.indexViewConfiguration = configuration;
    self.tableView.translucentForTableViewInNavigationBar = YES;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"carList" ofType:@"plist"];
    NSArray *dataSource = [NSArray arrayWithContentsOfFile:filePath];
    NSArray *arr = [CarLineModel mj_objectArrayWithKeyValuesArray:dataSource];
    
    [IndexListSort sortAndGroup:arr key:@"carLine" completion:^(bool isSuccess,
                                                                NSMutableArray *unGroupedArr,
                                                                NSMutableArray *sectionTitleArr,
                                                                NSMutableArray<NSMutableArray *> *sortedObjArr) {
        if (isSuccess) {
            self.firstLetterArray = sectionTitleArr;
            self.sortedModelArr = sortedObjArr;
            [self.tableView reloadData];
            
            self.tableView.indexViewDataSource = self.firstLetterArray.copy;
            self.tableView.startSection = 0;
        }
    }];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sortedModelArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sortedModelArr[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    CarLineModel *carLineM = self.sortedModelArr[indexPath.section][indexPath.row];
    cell.textLabel.text = carLineM.carLine;
    return cell;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    IndexHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:IndexHeaderView.reuseIdentifier];
    [headerView setWithTitle:self.firstLetterArray[section]];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return IndexHeaderView.headerViewHeight;
}

@end
