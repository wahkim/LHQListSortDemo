//
//  IndexViewConfiguration.h
//  LHQListSort
//
//  Created by Xhorse_iOS3 on 2021/1/16.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


extern const NSUInteger IndexViewInvalidSection;
extern const NSInteger IndexViewSearchSection;

typedef NS_ENUM(NSUInteger, IndexViewStyle) {
    IndexViewStyleDefault = 0,    // 指向点
    IndexViewStyleCenterToast,    // 中心提示弹层
};
@interface IndexViewConfiguration : NSObject

@property (nonatomic, assign, readonly) IndexViewStyle indexViewStyle;    // 索引提示风格

@property (nonatomic, strong) UIColor *indicatorBackgroundColor;            // 指示器背景颜色
@property (nonatomic, strong) UIColor *indicatorTextColor;                  // 指示器文字颜色
@property (nonatomic, strong) UIFont *indicatorTextFont;                    // 指示器文字字体
@property (nonatomic, assign) CGFloat indicatorHeight;                      // 指示器高度
@property (nonatomic, assign) CGFloat indicatorRightMargin;                 // 指示器距离右边屏幕距离（default有效）
@property (nonatomic, assign) CGFloat indicatorCornerRadius;                // 指示器圆角半径（centerToast有效）

@property (nonatomic, strong) UIColor *indexItemBackgroundColor;            // 索引元素背景颜色
@property (nonatomic, strong) UIColor *indexItemTextColor;                  // 索引元素文字颜色
@property (nonatomic, strong) UIFont *indexItemTextFont;                    // 索引元素文字字体
@property (nonatomic, strong) UIColor *indexItemSelectedBackgroundColor;    // 索引元素选中时背景颜色
@property (nonatomic, strong) UIColor *indexItemSelectedTextColor;          // 索引元素选中时文字颜色
@property (nonatomic, strong) UIFont *indexItemSelectedTextFont;            // 索引元素选中时文字字体
@property (nonatomic, assign) CGFloat indexItemHeight;                      // 索引元素高度
@property (nonatomic, assign) CGFloat indexItemRightMargin;                 // 索引元素距离右边屏幕距离
@property (nonatomic, assign) CGFloat indexItemsSpace;                      // 索引元素之间间隔距离

+ (instancetype)configuration;

+ (instancetype)configurationWithIndexViewStyle:(IndexViewStyle)indexViewStyle;

@end

