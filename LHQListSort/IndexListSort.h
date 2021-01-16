//
//  IndexListSort.h
//  LHQListSort
//
//  Created by Xhorse_iOS3 on 2021/1/15.
//

#import <Foundation/Foundation.h>

@interface SortConfiguration : NSObject

+ (instancetype)share;

/** 特殊字符最后单独分组所用的 分组名称。 default is @“#” */
@property (nonatomic, strong) NSString *specialCharSectionTitle;
/** 特殊字符所在 位置 YES = 开头，NO = 结尾, defalut is NO */
@property (nonatomic,assign) BOOL specialCharPositionIsFront;
/**
    剔除 特定字符开头的对象，不出现在最终结果集中，不要与 specialCharSectionTitle 冲突。 default is ""
    eg: 过滤所有数字开的对象  ignoreModelWithPrefix = @"0123456789"
 */
@property (strong, nonatomic) NSString * ignoreModelWithPrefix;
/**
    常用错误多音字 手动映射
    已经识别了：
        重庆=CQ，厦门=XM，长=C，
    如遇到默认选择错误的可以手动映射，使用格式{"匹配的文字":"对应的首字母(大写)"}
    eg:.polyphoneMapping = @{"长安":"CA","厦门":"XM"}
    如有发现常用的多音字 也可以在issue里提出来 定期更新
 */
@property (strong, nonatomic) NSMutableDictionary * polyphoneMapping;

@end

@interface SortModel : NSObject

@property (nonatomic, strong) NSString *string; // 用于排序的字符串
@property (nonatomic, strong) NSString *pinYin; // 用于排序的字符串对应的拼音
@property (nonatomic , strong) id object; // 用于排序的对象

@end

@interface IndexListSort : NSObject

/**
 异步获取拼音分组排序 (分组)

 @param objectArray 需要排序的数据源 可以是自定义模型数组，字符串数组，字典数组
 @param key 如果是字符串数组key传nil, 否则传入需要排序的字符串属性，或是字符串字段
 @param completion 异步回调block isSuccess为no
 */
+ (void)sortAndGroup:(NSArray*)objectArray
                 key:(NSString *)key
          completion:(void (^)(bool isSuccess, NSMutableArray *unGroupedArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray*>* sortedObjArr))completion;

@end


@interface NSString (Sort)

- (NSComparisonResult)compareSort:(NSString *)str;

@end
