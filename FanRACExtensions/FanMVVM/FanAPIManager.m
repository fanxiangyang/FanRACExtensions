//
//  FanAPIManager.m
//  FanRACExtensions
//
//  Created by 向阳凡 on 2019/3/21.
//  Copyright © 2019 向阳凡. All rights reserved.
//

#import "FanAPIManager.h"


@implementation FanAPIManager

-(instancetype)init{
    self=[super init];
    if (self) {
        self.timeoutInterval=20;
        self.needCookie=NO;
    }
    return self;
}

#pragma mark - set get 方法
-(AFHTTPSessionManager *)manager{
    if (!_manager) {
        _manager=[AFHTTPSessionManager manager];
        //返回二进制数据
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        //        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        //        [_manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        //        _manager.requestSerializer  =   [AFHTTPRequestSerializer serializer];
        //        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        //        [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        //Cookie
        if(_needCookie){
            if ([FanAppManager shareManager].phpsession.length>0) {
                [_manager.requestSerializer setValue:[NSString stringWithFormat:@"PHPSESSID=%@",[FanAppManager shareManager].phpsession] forHTTPHeaderField:@"Cookie"];
            }
        }
        //        [_manager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"User-Agent"];
    }
    return _manager;
}
-(NSString *)urlStr{
    if (!_urlStr) {
        _urlStr=[NSString stringWithFormat:@"%@",FanHost];
    };
    return _urlStr;
}

#pragma mark -  网络请求基本封装

-(RACSignal *)fan_requestWithURLString:(NSString *)URLString parameters:(nullable id)parameters{
    return [self.manager fan_racPOST:URLString parameters:parameters];
}


-(id)analysisValue:(id)value{
    if(![value isKindOfClass:[NSData class]]) {
        NSError *error = [NSError errorWithDomain:@"com.keyitech.Error" code:1000 userInfo:@{@"error":@"respone fail",NSLocalizedFailureReasonErrorKey:@"respone fail"}];
        return error;
    }
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:value options:NSJSONReadingAllowFragments error:nil];
    if (![result isKindOfClass:[NSDictionary class]]) {
        NSString *resultStr=[[NSString alloc]initWithData:value encoding:NSUTF8StringEncoding];
        if (resultStr==nil) {
            resultStr=@"data->UTF8 = null";
        }
        NSError *error = [NSError errorWithDomain:@"com.keyitech.Error" code:1000 userInfo:@{@"error":resultStr,NSLocalizedFailureReasonErrorKey:resultStr}];
        return error;
    }else{
        NSInteger resultCode = [[result objectForKey:@"result"] integerValue];
        if(resultCode==200||resultCode==300) {
            return result;
        }else{
            NSString *errorStr=result[@"msg"];
            if (errorStr==nil) {
                errorStr=@"no error message";
            }
            return [NSError errorWithDomain:@"com.keyitech.Error" code:resultCode userInfo:@{@"error":result,NSLocalizedFailureReasonErrorKey:errorStr}];
        }
        
    }
    
}
#pragma mark -  下面的方法要在继承类里面实现，这个是项目的基本网络封装类
//本项目只是例子，不在做一个子类，直接写在这里面了


-(RACSignal *)loginWithUserName:(NSString *)userName isEmail:(BOOL)isEmail countryCode:(NSString *)countryCode password:(NSString *)password{
    NSString * requestUrlStr=[self.urlStr stringByAppendingString:@"/api/user/login"];
    NSString *userNameKey=@"email";
    if (!isEmail) {
        userNameKey=@"mobile";
    }else{
        countryCode=@"0";
    }
    self.postDictionary=[@{userNameKey:userName,@"password":password,@"country_pre":countryCode} mutableCopy];
    
    self.needCookie=NO;
    return [[[[[self fan_requestWithURLString:requestUrlStr parameters:self.postDictionary]map:^id _Nullable(RACTuple * value) {
        //2.2这里可以过滤数据(RACTuple表示返回数据元组)
        RACTupleUnpack(id response,id responseObject)=value;
        return [self analysisValue:responseObject];
    }]flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        //2.3过滤错误数据
        if ([value isKindOfClass:[NSError class]]) {
            return [RACSignal error:value];
        }
        return [RACSignal return:value];
    }]logError]replayLazily];
    
//    [[self fan_requestWithURLString:self.urlStr parameters:self.postDictionary]reduceEach:^id _Nonnull(id response,id responseObject){
//        return RACTuplePack(response,responseObject);
//    }];
//    [[self fan_requestWithURLString:self.urlStr parameters:self.postDictionary]map:^id _Nullable(RACTuple * value) {
//        RACTupleUnpack(id response,id responseObject)=value;
//        NSLog(@"%@",responseObject);
//        return responseObject;
//    }];
}

@end
