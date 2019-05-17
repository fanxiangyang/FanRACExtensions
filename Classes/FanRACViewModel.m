//
//  FanRACViewModel.m
//  FanRACExtensions
//
//  Created by 向阳凡 on 2019/3/14.
//  Copyright © 2019 向阳凡. All rights reserved.
//

#import "FanRACViewModel.h"
#import <ReactiveObjC/ReactiveObjC.h>

static const NSTimeInterval FanRACViewModelInactiveThrottleInterval = 1;

@interface FanRACViewModel ()


@property(nonatomic,strong,readwrite)RACSignal *didBecomeRunningSignal;
@property(nonatomic,strong,readwrite)RACSignal *didBecomeStopSignal;


// Improves the performance of KVO on the receiver.
@property (atomic) void *observationInfo;



@end


@implementation FanRACViewModel


-(void)setRunning:(BOOL)running{
    if (running==_running) {
        return;
    }
    //willChangeValueForKey 为了触发kvo 方法
    [self willChangeValueForKey:@keypath(self.running)];
    _running=running;
    [self didChangeValueForKey:@keypath(self.running)];
}
-(RACSignal *)didBecomeRunningSignal{
    if (_didBecomeRunningSignal == nil) {
        @weakify(self);
        //RACObserve 监听属性
        _didBecomeRunningSignal=[[[RACObserve(self, running) filter:^BOOL(id  _Nullable value) {
            //过滤，当running=YES执行
            return [value boolValue];
        }]map:^id _Nullable(id  _Nullable value) {
            @strongify(self);
            return self;
        }]setNameWithFormat:@"%@ -didBecomeRunningSignal",self ];
    }
    return _didBecomeRunningSignal;
}

-(RACSignal *)didBecomeStopSignal{
    if (_didBecomeStopSignal == nil) {
        @weakify(self);
        _didBecomeStopSignal=[[[RACObserve(self, running) filter:^BOOL(id  _Nullable value) {
            return ![value boolValue];
        }]map:^id _Nullable(id  _Nullable value) {
            @strongify(self);
            return self;
        }]setNameWithFormat:@"%@ -didBecomeStopSignal",self ];
    }
    return _didBecomeStopSignal;
}
#pragma mark - Activation
- (RACSignal *)forwardSignalWhileRunning:(RACSignal *)signal {
    NSParameterAssert(signal != nil);
    //监听信号
    RACSignal *runningSignal = RACObserve(self, running);
    //创建一个信号
    return [[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        //创建一个销毁信号队列
        RACCompoundDisposable *disposable = [RACCompoundDisposable compoundDisposable];
        __block RACDisposable *signalDisposable = nil;
        RACDisposable *activeDisposable = [runningSignal subscribeNext:^(id  _Nullable x) {
            if ([x boolValue]) {
                //running=YES
                signalDisposable = [signal subscribeNext:^(id value) {
                    [subscriber sendNext:value];
                } error:^(NSError *error) {
                    [subscriber sendError:error];
                }];
                
                if (signalDisposable != nil) {
                    [disposable addDisposable:signalDisposable];
                }
            }else{
                [signalDisposable dispose];
                [disposable removeDisposable:signalDisposable];
                signalDisposable = nil;
            }
        } error:^(NSError * _Nullable error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        if (activeDisposable != nil) [disposable addDisposable:activeDisposable];
        return disposable;
    }]setNameWithFormat:@"%@ -forwardSignalWhileRunning: %@", self, signal];
  
}

- (RACSignal *)throttleSignalWhileStop:(RACSignal *)signal {
    NSParameterAssert(signal != nil);
    
    signal = [signal replayLast];
    return [[[[[RACObserve(self, running) takeUntil:[signal ignoreValues]]combineLatestWith:signal]throttle:FanRACViewModelInactiveThrottleInterval valuesPassingTest:^BOOL(id  _Nullable next) {
        RACTuple *xs=next;
        BOOL active = [xs.first boolValue];
        return !active;
    }]reduceEach:^(NSNumber *running, id value){
        return value;
    }]setNameWithFormat:@"%@ -throttleSignalWhileStop: %@", self, signal];
}
#pragma mark - NSKeyValueObserving

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqual:@keypath(FanRACViewModel.new, running)]) {
        return NO;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}
@end
