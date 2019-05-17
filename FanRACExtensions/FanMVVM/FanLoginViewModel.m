//
//  FanLoginViewModel.m
//  FanRACExtensions
//
//  Created by 向阳凡 on 2019/3/14.
//  Copyright © 2019 向阳凡. All rights reserved.
//

#import "FanLoginViewModel.h"
#import "FanAPIManager.h"

@interface FanLoginViewModel()

@property (nonatomic, strong) FanAPIManager *apiManager;


@end

@implementation FanLoginViewModel

- (instancetype)init{
    if((self = [super init])) {
        [[self.didBecomeRunningSignal skip:1]
         subscribeNext:^(id  _Nullable x) {
             NSLog(@"%s ---Running!", __func__);
         }];
        [[self.didBecomeStopSignal skip:1]
         subscribeNext:^(id x) {
             NSLog(@"%s ---Stop!", __func__);
         }];
        
        self.apiManager=[[FanAPIManager alloc]init];
    }
    return self;
}

-(RACCommand *)loginCommand{
    if (_loginCommand==nil) {
        @weakify(self);
        _loginCommand=[[RACCommand alloc]initWithEnabled:[RACSignal combineLatest:@[RACObserve(self, userName), RACObserve(self, password)] reduce:^id (NSString *userName, NSString *password){
            //校验输入规则，同时会绑定按钮的enable属性(这里可以对输入校验)
//            NSLog(@"%@===%@",userName,password);
            return @(YES);
        }] signalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            //2.网络请求得到结果
            ShowHUDIMPMessage(@"加载中");
            @strongify(self);
            return [self.apiManager loginWithUserName:self.userName isEmail:NO countryCode:@"86" password:self.password];
//            return [[[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
//                //                [subscriber sendError:nil];
//                sleep(2);
//                [subscriber sendNext:@{@"userName":self.userName,@"password":self.password}];
//                [subscriber sendCompleted];
//                return [RACDisposable disposableWithBlock:^{
//                     //block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
//                    HideHUDAll;
//                }];
//            }]map:^id _Nullable(id  _Nullable value) {
//                return value;
//            }] logError] replayLazily];
        }] ;
        //concat: 连接信号,第一个信号必须发送完成，第二个信号才会被激活
        // 1.RACCommand有个执行信号源executionSignals，这个是signal of signals(信号的信号),意思是信号发出的数据是信号，不是普通的类型。
        // 2.订阅executionSignals就能拿到RACCommand中返回的信号，然后订阅signalBlock返回的信号，就能获取发出的值。
        //把网络请求的信号的数据合并到这个输出里面
        [[_loginCommand.executionSignals concat] subscribeNext:^(id  _Nullable x) {
            //3.订阅结果
            @strongify(self);
            self.modelDic = x;
        }];
//        [_loginCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
//
//        }];
        [_loginCommand.errors subscribeNext:^(NSError * _Nullable x) {
            //4.订阅错误信息
            @strongify(self);
            self.error = x;
            //下面这个是我测试打印的消息，因为拿到的是二进制，后台的崩溃数据，不是正常的error
            NSData *errorData=self.error.userInfo[FanRACAFNErrorKey];
            NSString *resultStr=[[NSString alloc]initWithData:errorData encoding:NSUTF8StringEncoding];
            if (resultStr==nil) {
                resultStr=@"data->UTF8 = null";
            }
            NSLog(@"error:%@",resultStr);
        }];
        
        [_loginCommand.executing  subscribeNext:^(NSNumber * _Nullable x) {
            //订阅执行的状态
            @strongify(self);
            //如果VC文件里面订阅了这个值，就能拿到这个值的状态信息，做出不同的UI展示
            self.executing = x;
            if ([self.executing boolValue]) {
                HideHUDAll;
            }
        }];
         
    }
    return _loginCommand;
}

@end
