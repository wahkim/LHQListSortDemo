//
//  UITableView+IndexView.m
//  LHQListSort
//
//  Created by Xhorse_iOS3 on 2021/1/16.
//

#import "UITableView+IndexView.h"
#import "IndexView.h"
#import <objc/runtime.h>

@interface WeakProxy : NSObject

@property (nonatomic, weak) id target;

@end

@implementation WeakProxy

@end

@interface UITableView () <IndexViewDelegate>

@property (nonatomic, strong) IndexView *indexView;

@end

@implementation UITableView (IndexView)

+ (void)load
{
    [self swizzledSelector:@selector(IndexView_layoutSubviews) originalSelector:@selector(layoutSubviews)];
}

+ (void)swizzledSelector:(SEL)swizzledSelector originalSelector:(SEL)originalSelector
{
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)IndexView_layoutSubviews {
    [self IndexView_layoutSubviews];
    
    if (!self.indexView) {
        return;
    }
    if (self.superview && !self.indexView.superview) {
        [self.superview addSubview:self.indexView];
    }
    else if (!self.superview && self.indexView.superview) {
        [self.indexView removeFromSuperview];
    }
    if (!CGRectEqualToRect(self.indexView.frame, self.frame)) {
        self.indexView.frame = self.frame;
    }
    [self.indexView refreshCurrentSection];
}

#pragma mark - IndexViewDelegate

- (void)indexView:(IndexView *)indexView didSelectAtSection:(NSUInteger)section
{
    if (self.indexViewDelegate && [self.delegate respondsToSelector:@selector(tableView:didSelectIndexViewAtSection:)]) {
        [self.indexViewDelegate tableView:self didSelectIndexViewAtSection:section];
    }
}

- (NSUInteger)sectionOfIndexView:(IndexView *)indexView tableViewDidScroll:(UITableView *)tableView
{
    if (self.indexViewDelegate && [self.delegate respondsToSelector:@selector(sectionOfTableViewDidScroll:)]) {
        return [self.indexViewDelegate sectionOfTableViewDidScroll:self];
    } else {
        return IndexViewInvalidSection;
    }
}

#pragma mark - Public Methods

- (void)refreshCurrentSectionOfIndexView {
    [self.indexView refreshCurrentSection];
}

#pragma mark - Private Methods

- (IndexView *)createIndexView {
    IndexView *indexView = [[IndexView alloc] initWithTableView:self configuration:self.indexViewConfiguration];
    indexView.translucentForTableViewInNavigationBar = self.translucentForTableViewInNavigationBar;
    indexView.startSection = self.startSection;
    indexView.delegate = self;
    return indexView;
}

#pragma mark - Getter and Setter

- (IndexView *)indexView
{
    return objc_getAssociatedObject(self, @selector(indexView));
}

- (void)setIndexView:(IndexView *)indexView
{
    if (self.indexView == indexView) return;
    
    objc_setAssociatedObject(self, @selector(indexView), indexView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (IndexViewConfiguration *)indexViewConfiguration
{
    IndexViewConfiguration *indexViewConfiguration = objc_getAssociatedObject(self, @selector(indexViewConfiguration));
    if (!indexViewConfiguration) {
        indexViewConfiguration = [IndexViewConfiguration configuration];
    }
    return indexViewConfiguration;
}

- (void)setIndexViewConfiguration:(IndexViewConfiguration *)indexViewConfiguration
{
    if (self.indexViewConfiguration == indexViewConfiguration) return;
    
    objc_setAssociatedObject(self, @selector(indexViewConfiguration), indexViewConfiguration, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<TableViewSectionIndexDelegate>)indexViewDelegate
{
    WeakProxy *weakProxy = objc_getAssociatedObject(self, @selector(indexViewDelegate));
    return weakProxy.target;
}

- (void)setIndexViewDelegate:(id<TableViewSectionIndexDelegate>)indexViewDelegate
{
    if (self.indexViewDelegate == indexViewDelegate) return;
    
    WeakProxy *weakProxy = [WeakProxy new];
    weakProxy.target = indexViewDelegate;
    objc_setAssociatedObject(self, @selector(indexViewDelegate), weakProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)translucentForTableViewInNavigationBar
{
    NSNumber *number = objc_getAssociatedObject(self, @selector(translucentForTableViewInNavigationBar));
    return number.boolValue;
}

- (void)setTranslucentForTableViewInNavigationBar:(BOOL)translucentForTableViewInNavigationBar
{
    if (self.translucentForTableViewInNavigationBar == translucentForTableViewInNavigationBar) return;
    
    objc_setAssociatedObject(self, @selector(translucentForTableViewInNavigationBar), @(translucentForTableViewInNavigationBar), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.indexView.translucentForTableViewInNavigationBar = translucentForTableViewInNavigationBar;
}

- (NSArray<NSString *> *)indexViewDataSource
{
    return objc_getAssociatedObject(self, @selector(indexViewDataSource));
}

- (void)setIndexViewDataSource:(NSArray<NSString *> *)indexViewDataSource
{
    if (self.indexViewDataSource == indexViewDataSource) return;
    objc_setAssociatedObject(self, @selector(indexViewDataSource), indexViewDataSource.copy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (indexViewDataSource.count > 0) {
        if (!self.indexView) {
            self.indexView = [self createIndexView];
            [self.superview addSubview:self.indexView];
        }
        self.indexView.dataSource = indexViewDataSource.copy;
        self.indexView.hidden = NO;
    }
    else {
        self.indexView.hidden = YES;
    }
}

- (NSUInteger)startSection {
    NSNumber *number = objc_getAssociatedObject(self, @selector(startSection));
    return number.unsignedIntegerValue;
}

- (void)setStartSection:(NSUInteger)startSection {
    if (self.startSection == startSection) return;
    
    objc_setAssociatedObject(self, @selector(startSection), @(startSection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.indexView.startSection = startSection;
}

@end
