//
//  CarLineModel.h
//  LHQListSort
//
//  Created by Xhorse_iOS3 on 2021/1/15.
//

#import <Foundation/Foundation.h>

@interface CarModel : NSObject

@property (nonatomic, copy) NSString *attributeName;
@property (nonatomic, assign) NSInteger chargeAmount;
@property (nonatomic, copy) NSString *carId;
@property (nonatomic, copy) NSString *imgDescript;
@property (nonatomic, strong) NSArray *imgList;
@property (nonatomic, assign) BOOL imgNeed;
@property (nonatomic, copy) NSString *remark;
@property (nonatomic, copy) NSString *vin;

@end

@interface CarLineModel : NSObject

@property (nonatomic, copy) NSString *carLine;
@property (nonatomic, strong) NSArray <CarModel*>*carmodelList;

@end

