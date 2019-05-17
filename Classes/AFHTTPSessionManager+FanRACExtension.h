//
//  AFHTTPSessionManager+FanRACExtension.h
//  FanRACExtensions
//
//  Created by 向阳凡 on 2019/3/21.
//  Copyright © 2019 向阳凡. All rights reserved.
//

/**
 *      依赖库:
 *      pod 'AFNetworking', '>= 3.2.1'
 *      pod 'ReactiveObjC', '>= 3.1.0'
 *
 *
 */

#import <AFNetworking/AFNetworking.h>
#import <ReactiveObjC/ReactiveObjC.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const FanRACAFNErrorKey;

@interface AFHTTPSessionManager (FanRACExtension)
///GET
-(RACSignal*)fan_racGET:(NSString *)URLString parameters:(nullable id)parameters;
///GET-Headers
-(RACSignal*)fan_racGET:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers;

///HEAD
-(RACSignal*)fan_racHEAD:(NSString *)URLString parameters:(nullable id)parameters;
///HEAD-Headers
-(RACSignal*)fan_racHEAD:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers;

///POST
-(RACSignal*)fan_racPOST:(NSString *)URLString parameters:(nullable id)parameters;
///POST-Headers
-(RACSignal*)fan_racPOST:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers;

///PUT
-(RACSignal*)fan_racPUT:(NSString *)URLString parameters:(nullable id)parameters;
///PUT-Headers
-(RACSignal*)fan_racPUT:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers;

///PATH
-(RACSignal*)fan_racPATCH:(NSString *)URLString parameters:(nullable id)parameters;
///PATH-Headers
-(RACSignal*)fan_racPATCH:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers;

///DELETE
-(RACSignal*)fan_racDELETE:(NSString *)URLString parameters:(nullable id)parameters;
///DELETE-Headers
-(RACSignal*)fan_racDELETE:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers;

///GET-POST-PUT等等-通用方法
- (RACSignal *)fan_racWithHTTPMethod:(NSString *)method
                           URLString:(NSString *)URLString
                          parameters:(nullable id)parameters
                             headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                      uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                    downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress;


///POST-Headers-Upload File(上传文件)
-(RACSignal*)fan_racPOST:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block progress:(void (^)(NSProgress * _Nonnull))uploadProgress;


@end

NS_ASSUME_NONNULL_END
