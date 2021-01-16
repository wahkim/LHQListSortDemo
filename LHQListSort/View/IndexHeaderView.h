//
//  IndexHeaderView.h
//  LHQListSort
//
//  Created by Xhorse_iOS3 on 2021/1/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IndexHeaderView : UITableViewHeaderFooterView

+ (CGFloat)headerViewHeight;
+ (NSString *)reuseIdentifier;

- (void)setWithTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
