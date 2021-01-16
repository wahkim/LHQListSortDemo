//
//  IndexHeaderView.m
//  LHQListSort
//
//  Created by Xhorse_iOS3 on 2021/1/16.
//

#import "IndexHeaderView.h"

@interface IndexHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation IndexHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.frame = CGRectMake(15, 0, UIScreen.mainScreen.bounds.size.width - 15 * 2, 30);
    }
    return self;
}

+ (CGFloat)headerViewHeight {
    return 30;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self);
}

- (void)setWithTitle:(NSString *)title {
    self.titleLabel.text = title;
}


#pragma mark - Lazy Load

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor orangeColor];
    }
    return _titleLabel;
}

@end
