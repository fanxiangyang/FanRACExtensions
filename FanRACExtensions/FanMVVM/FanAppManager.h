//
//  FanAppManager.h
//  FanRACExtensions
//
//  Created by 向阳凡 on 2019/3/21.
//  Copyright © 2019 向阳凡. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FanAppManager : NSObject

@property(nonatomic,strong)NSString *http_host;


@property(nonatomic,strong)NSString *phpsession;



+(instancetype)shareManager;




@end

NS_ASSUME_NONNULL_END
