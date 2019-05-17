//
//  FanAppManager.m
//  FanRACExtensions
//
//  Created by 向阳凡 on 2019/3/21.
//  Copyright © 2019 向阳凡. All rights reserved.
//

#import "FanAppManager.h"

@implementation FanAppManager
-(instancetype)init{
    self=[super init];
    if (self) {
        
    }
    return self;
}
+(instancetype)shareManager{
    static FanAppManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[[FanAppManager alloc]init];
        
    });
    return manager;
}

-(NSString *)http_host{
    if (_http_host==nil) {
        _http_host = @"http://neuro.coolphper.com";
    }
    return _http_host;
}

@end
