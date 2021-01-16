//
//  IndexListSort.m
//  LHQListSort
//
//  Created by Xhorse_iOS3 on 2021/1/15.
//

#import "IndexListSort.h"
#import <objc/runtime.h>

@implementation SortConfiguration

+ (instancetype)share {
    static SortConfiguration *config = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        config = [[SortConfiguration alloc] init];
    });
    return config;
}

- (instancetype)init {
    if (self = [super init]) {
        [self configDefault];
    }
    return self;
}

- (void)configDefault {
    _specialCharSectionTitle = @"#";
    _specialCharPositionIsFront = YES;
    _ignoreModelWithPrefix = @"";
    _polyphoneMapping = [NSMutableDictionary dictionaryWithDictionary:
                         @{@"重庆":@"CQ",
                           @"厦门":@"XM",
                           @"长安":@"CA",
                           @"长城":@"CC",
                           @"沈":@"S",
                           }];
}

-(void)setPolyphoneMapping:(NSMutableDictionary *)polyphoneMapping{
    [_polyphoneMapping addEntriesFromDictionary:polyphoneMapping];
}

@end

@implementation SortModel

@end

@implementation IndexListSort

+ (void)sortAndGroup:(NSArray*)objectArray
                 key:(NSString *)key
          completion:(void (^)(bool isSuccess, NSMutableArray *unGroupedArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray*>* sortedObjArr))completion {
    
    if (!objectArray || objectArray.count == 0) {
        completion(YES,@[].mutableCopy,@[].mutableCopy,@[].mutableCopy);
        return;
    }
    // 属性名检测合法性
    BOOL containKey = NO;
    NSObject *obj = objectArray.firstObject;
    if (key == nil) {
        if (![obj isKindOfClass:NSString.class]) {
            NSLog(@"数组内元素不是字符串类型,如果是对象类型，请传key");
            completion(NO, nil, nil, nil);
            return;
        }
        containKey = YES;
    }else{
        Class cla = ((NSObject*)objectArray.firstObject).class;
        while (cla != Nil){
            unsigned int outCount, i;
            Ivar *ivars = class_copyIvarList(cla, &outCount);
            for (i = 0; i < outCount; i++) {
                Ivar property = ivars[i];
                NSString *keyName = [NSString stringWithCString:ivar_getName(property) encoding:NSUTF8StringEncoding];
                NSString *tempKey = [NSString stringWithFormat:@"_%@",key];
                if ([keyName isEqualToString:tempKey]) {
                    containKey = YES;
                    break;
                }
            }
            if (containKey == YES) {
                break;
            }
            cla = class_getSuperclass(cla.class);
        }
    }
    if (!containKey) {
        NSLog(@"数组内元素未包含指定属性");
        completion(NO, nil, nil, nil);
        return;
    }

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    

    //异步执行
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //将数据 转换为 BMChineseSortModel
        NSMutableArray *sortModelArray = [NSMutableArray arrayWithCapacity:0];

        [objectArray enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SortModel *model = [self getModelWithObj:obj key:key];
            if (model) {
                //对 数组的插入操作 上锁
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                [sortModelArray addObject:model];
                dispatch_semaphore_signal(semaphore);
            }
        }];

        //根据BMChineseSortModel的pinYin字段 升序 排列
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"pinYin" ascending:YES selector:@selector(compareSort:)];
        [sortModelArray sortUsingDescriptors:@[sortDescriptor]];

        //不分组
        NSMutableArray *unSortedArr = [NSMutableArray array];

        //分组
        NSMutableArray<NSString *> *sectionTitleArr = [NSMutableArray array];
        NSMutableArray<NSMutableArray *> *sortedObjArr = [NSMutableArray array];
        NSMutableArray *newSection = [NSMutableArray array];
        NSString *lastTitle;
        //拼音分组 稳定的分组排序 所以组内不需要再排
        for (SortModel* object in sortModelArray) {
            NSString *firstLetter = [object.pinYin substringToIndex:1];
            id obj = object.object;
            [unSortedArr addObject:obj];
            //不同
            if(![lastTitle isEqualToString:firstLetter]){
                [sectionTitleArr addObject:firstLetter];
                //分组
                newSection = [NSMutableArray array];
                [sortedObjArr addObject:newSection];
                [newSection  addObject:obj];
                //用于下一次比较
                lastTitle = firstLetter;
            }else{//相同
                [newSection  addObject:obj];
            }
        }

        //回主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(YES,unSortedArr,sectionTitleArr,sortedObjArr);
        });
    });
}

// 将对象转为SortModel
+ (SortModel *)getModelWithObj:(id)obj key:(NSString *)key {
    SortModel *model = [[SortModel alloc]init];
    model.object = obj;
    if (!key) {
        model.string = obj;
    }else{
        model.string = [obj valueForKeyPath:key];
    }
    // 提出空白字符
    model.string = [model.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(model.string == nil || model.string.length == 0){
        model.string = SortConfiguration.share.specialCharSectionTitle;
    }else{
        //过滤 ignoreModelWithPrefix
        NSString *prefix = [model.string substringToIndex:1];
        if (![SortConfiguration.share.ignoreModelWithPrefix containsString:prefix]) {
            //是否将字母与汉字拼音一起排序？？？？ （暂不考虑）
            //获取拼音首字母
            model.pinYin = [self getFirstLetter:model.string];
        }else{
            return nil;
        }
    }
    return model;
}

// 获取首字母
+ (NSString *)getFirstLetter:(NSString *)title {

    __block NSString *newTitle = [title uppercaseString];
    // 多音字替换
    [SortConfiguration.share.polyphoneMapping enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        newTitle = [newTitle stringByReplacingOccurrencesOfString:key withString:obj];
    }];

    NSMutableString *result = [NSMutableString string];

    NSArray *wordArr = [[IndexListSort transform:newTitle] componentsSeparatedByString:@" "];
    for (NSString* word in wordArr) {
        // 如果word是小写 为汉字转的拼音 提取首字符 否则 保留全部
        char c = [word characterAtIndex:0];
        if ((c>96)&&(c<123)) {
            [result appendFormat:@"%c",c];
        }else{
            [result appendString:word];
        }
    }

    //全转为大写
    NSString *upperCaseStr = [result uppercaseString];
    //判断第一个字符是否为字母 英文或者中文转拼音后都是字母开头
    if ([upperCaseStr characterAtIndex:0] >= 'A' && [upperCaseStr characterAtIndex:0] <= 'Z') {
        return upperCaseStr;
    }else{//所有非字母的全分为 特殊字符分类中
        return SortConfiguration.share.specialCharSectionTitle;
    }
}

+ (NSString *)transform:(NSString *)word {
    NSMutableString *pinyin = [word mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    return pinyin;
}

@end


@implementation NSString (Sort)

- (NSComparisonResult)compareSort:(NSString *)str {
    NSString *s = SortConfiguration.share.specialCharSectionTitle;
    BOOL b = SortConfiguration.share.specialCharPositionIsFront;
    
    NSComparisonResult res = NSOrderedDescending;
    if ([self isEqualToString:s]){
        //相同
        if ([str isEqualToString:s]) {
            res = NSOrderedSame;
        }
        res = b ? NSOrderedAscending : NSOrderedDescending;
    }else if ([str isEqualToString:s]){
        res = b ? NSOrderedDescending : NSOrderedAscending;
    }else{
        res = [self localizedStandardCompare:str];
    }
    //如过相等就返回
    if (res == NSOrderedSame) {
        res = NSOrderedAscending;
    }
    return res;
}
@end
