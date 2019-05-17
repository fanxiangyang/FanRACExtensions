//
//  AFHTTPSessionManager+FanRACExtension.m
//  FanRACExtensions
//
//  Created by 向阳凡 on 2019/3/21.
//  Copyright © 2019 向阳凡. All rights reserved.
//

#import "AFHTTPSessionManager+FanRACExtension.h"


NSString *const FanRACAFNErrorKey = @"error";

@implementation AFHTTPSessionManager (FanRACExtension)


-(RACSignal*)fan_racGET:(NSString *)URLString parameters:(nullable id)parameters{
    return [[self fan_racWithHTTPMethod:@"GET" URLString:URLString parameters:parameters headers:nil uploadProgress:nil downloadProgress:nil]setNameWithFormat:@"%@ -fan_racGET:",self.class];
}
-(RACSignal*)fan_racGET:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers{
    return [[self fan_racWithHTTPMethod:@"GET" URLString:URLString parameters:parameters headers:headers uploadProgress:nil downloadProgress:nil]setNameWithFormat:@"%@ -fan_racGET:",self.class];
}

-(RACSignal*)fan_racHEAD:(NSString *)URLString parameters:(nullable id)parameters{
    return [[self fan_racWithHTTPMethod:@"HEAD" URLString:URLString parameters:parameters headers:nil uploadProgress:nil downloadProgress:nil]setNameWithFormat:@"%@ -fan_racHEAD:",self.class];
}
-(RACSignal*)fan_racHEAD:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers{
    return [[self fan_racWithHTTPMethod:@"HEAD" URLString:URLString parameters:parameters headers:headers uploadProgress:nil downloadProgress:nil]setNameWithFormat:@"%@ -fan_racHEAD:",self.class];
}


-(RACSignal*)fan_racPOST:(NSString *)URLString parameters:(nullable id)parameters{
    return [[self fan_racWithHTTPMethod:@"POST" URLString:URLString parameters:parameters headers:nil uploadProgress:nil downloadProgress:nil]setNameWithFormat:@"%@ -fan_racPOST:",self.class];
}
-(RACSignal*)fan_racPOST:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers{
    return [[self fan_racWithHTTPMethod:@"POST" URLString:URLString parameters:parameters headers:headers uploadProgress:nil downloadProgress:nil]setNameWithFormat:@"%@ -fan_racPOST:",self.class];
}


-(RACSignal*)fan_racPUT:(NSString *)URLString parameters:(nullable id)parameters{
    return [[self fan_racWithHTTPMethod:@"PUT" URLString:URLString parameters:parameters headers:nil uploadProgress:nil downloadProgress:nil]setNameWithFormat:@"%@ -fan_racPUT:",self.class];
}
-(RACSignal*)fan_racPUT:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers{
    return [[self fan_racWithHTTPMethod:@"PUT" URLString:URLString parameters:parameters headers:headers uploadProgress:nil downloadProgress:nil]setNameWithFormat:@"%@ -fan_racPUT:",self.class];
}


-(RACSignal*)fan_racPATCH:(NSString *)URLString parameters:(nullable id)parameters{
       return [[self fan_racWithHTTPMethod:@"PATCH" URLString:URLString parameters:parameters headers:nil uploadProgress:nil downloadProgress:nil]setNameWithFormat:@"%@ -fan_racPATCH:",self.class];
}
-(RACSignal*)fan_racPATCH:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers{
    return [[self fan_racWithHTTPMethod:@"PATCH" URLString:URLString parameters:parameters headers:headers uploadProgress:nil downloadProgress:nil]setNameWithFormat:@"%@ -fan_racPATCH:",self.class];
}


-(RACSignal*)fan_racDELETE:(NSString *)URLString parameters:(nullable id)parameters{
    return [[self fan_racWithHTTPMethod:@"DELETE" URLString:URLString parameters:parameters headers:nil uploadProgress:nil downloadProgress:nil]setNameWithFormat:@"%@ -fan_racDELETE:",self.class];
}
-(RACSignal*)fan_racDELETE:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers{
    return [[self fan_racWithHTTPMethod:@"DELETE" URLString:URLString parameters:parameters headers:headers uploadProgress:nil downloadProgress:nil]setNameWithFormat:@"%@ -fan_racDELETE:",self.class];
}


-(RACSignal*)fan_racPOST:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block progress:(void (^)(NSProgress * _Nonnull))uploadProgress{
    return [[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSError *serializationError = nil;
        NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:block error:&serializationError];
        for (NSString *headerField in headers.keyEnumerator) {
            [request addValue:headers[headerField] forHTTPHeaderField:headerField];
        }
        if (serializationError) {
        
            [subscriber sendError:serializationError];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }else{
            __block NSURLSessionDataTask *task = [self uploadTaskWithStreamedRequest:request progress:uploadProgress completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                if (error) {
                    NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
                    if (responseObject) {
                        userInfo[FanRACAFNErrorKey] = responseObject;
                    }
                    NSError *errorWithRes = [NSError errorWithDomain:error.domain code:error.code userInfo:[userInfo copy]];
                    [subscriber sendError:errorWithRes];
                } else {
                    [subscriber sendNext:RACTuplePack(response,responseObject)];
                    [subscriber sendCompleted];
                }
            }];
            
            [task resume];
            return [RACDisposable disposableWithBlock:^{
                [task cancel];
            }];
        }
    }]setNameWithFormat:@"%@ -fan_racPOST: %@, parameters: %@, constructingBodyWithBlock:", self.class, URLString, parameters];
    
}
- (RACSignal *)fan_racWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(nullable id)parameters
                                         headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
{
    return [[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSError *serializationError = nil;
        NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
        for (NSString *headerField in headers.keyEnumerator) {
            [request addValue:headers[headerField] forHTTPHeaderField:headerField];
        }
        if (serializationError) {
            [subscriber sendError:serializationError];
            return [RACDisposable disposableWithBlock:^{
            }];
        }else{
            __block NSURLSessionDataTask *dataTask = nil;
            dataTask = [self dataTaskWithRequest:request uploadProgress:uploadProgress downloadProgress:downloadProgress completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                if (error) {
                    NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
                    if (responseObject) {
                        userInfo[FanRACAFNErrorKey] = responseObject;
                    }
                    NSError *errorWithRes = [NSError errorWithDomain:error.domain code:error.code userInfo:[userInfo copy]];
                    [subscriber sendError:errorWithRes];
                } else {
                    [subscriber sendNext:RACTuplePack(response,responseObject)];
                    [subscriber sendCompleted];
                }
            }];
            [dataTask resume];
            return [RACDisposable disposableWithBlock:^{
                [dataTask cancel];
            }];
        }
       
    }]setNameWithFormat:@"%@ -fan_racWithHTTPMethod:", self.class];
}
@end
