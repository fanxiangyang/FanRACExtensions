//
//  FanAPIManager.h
//  FanRACExtensions
//
//  Created by 向阳凡 on 2019/3/21.
//  Copyright © 2019 向阳凡. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <AFNetworking/AFNetworking.h>
#import "AFHTTPSessionManager+FanRACExtension.h"

NS_ASSUME_NONNULL_BEGIN

@interface FanAPIManager : NSObject


@property(nonatomic,strong)AFHTTPSessionManager *manager;

//是否显示加载等待框
@property (nonatomic, assign) BOOL showLoading;
//是否需要cookie
@property (nonatomic, assign) BOOL needCookie;
//接口超时
@property(nonatomic,assign)CGFloat timeoutInterval;
//接口URL
@property (nonatomic, copy) NSString *urlStr;
//存放参数的字典
@property (nonatomic, strong)NSMutableDictionary *postDictionary;

#pragma mark - 信号相关-网络请求基本封装

-(RACSignal *)fan_requestWithURLString:(NSString *)URLString parameters:(nullable id)parameters;



#pragma mark -  下面的方法要在继承类里面实现，这个是项目的基本网络封装类
//本项目只是例子，不在做一个子类，直接写在这里面了

-(RACSignal *)loginWithUserName:(NSString *)userName isEmail:(BOOL)isEmail countryCode:(NSString *)countryCode password:(NSString *)password;



@end

NS_ASSUME_NONNULL_END
