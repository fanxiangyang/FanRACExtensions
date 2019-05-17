//
//  FanLoginViewModel.h
//  FanRACExtensions
//
//  Created by 向阳凡 on 2019/3/14.
//  Copyright © 2019 向阳凡. All rights reserved.
//

#import "FanRACViewModel.h"
#import <ReactiveObjC/ReactiveObjC.h>

NS_ASSUME_NONNULL_BEGIN

@interface FanLoginViewModel : FanRACViewModel
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) RACCommand *listCommand;
@property (nonatomic, strong) RACCommand *loginCommand;


/**
 *  错误
 */
@property (nonatomic, strong) NSError *error;

/**
 *  是否正在执行
 */
@property (nonatomic, strong) NSNumber *executing;

@property (nonatomic, strong) NSMutableDictionary *modelDic;


@end

NS_ASSUME_NONNULL_END
