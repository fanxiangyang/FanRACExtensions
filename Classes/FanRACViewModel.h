//
//  FanRACViewModel.h
//  FanRACExtensions
//
//  Created by 向阳凡 on 2019/3/14.
//  Copyright © 2019 向阳凡. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@class RACSignal;

@interface FanRACViewModel : NSObject

///视图和模型是否处于活跃状态 默认 NO
@property(nonatomic,assign)BOOL running;
/**
 活跃信号
@description 订阅时，观察接收者的“running”属性从“NO”更改为“YES”如果接收器当前处于活动状态，此信号触发
 */
@property(nonatomic,strong,readonly)RACSignal *didBecomeRunningSignal;
/**
 不活跃信号
 @description 订阅时，观察接收者的“running”属性从“YES”更改为“NO”如果接收器当前处于不活动状态，此信号触发
 */
@property(nonatomic,strong,readonly)RACSignal *didBecomeStopSignal;

- (RACSignal *)forwardSignalWhileRunning:(RACSignal *)signal;

- (RACSignal *)throttleSignalWhileStop:(RACSignal *)signal;

@end

NS_ASSUME_NONNULL_END
