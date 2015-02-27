//
//  AFSharedClient.m
//  AFNetworking iOS Example
//
//  Created by family on 15/2/27.
//  Copyright (c) 2015年 Gowalla. All rights reserved.
//

#import "AFSharedClient.h"

@interface AFSharedClient ()
@property (strong, nonatomic) AFHTTPRequestOperationManager *requestManager;
@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;
@property (assign, nonatomic) CGFloat systemVersion;
@end

@implementation AFSharedClient
+ (instancetype)sharedManager{
    static AFSharedClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[AFSharedClient alloc] init];
    });
    return sharedClient;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        self.systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if(_systemVersion >= 7.0){
            AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
            self.sessionManager = sessionManager;
            AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
            responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"text/html", @"application/json",@"text/plain",nil];
            self.sessionManager.responseSerializer = responseSerializer;
        }else{
            AFHTTPRequestOperationManager *requestManager = [[AFHTTPRequestOperationManager alloc] init];
            _requestManager = requestManager;
            _requestManager.operationQueue.maxConcurrentOperationCount = 5;
        }
    }
    return self;
}
- (void)addPOST:(NSString *)urlstring
      paragrams:(NSDictionary *)paragrams
        success:(void (^)(NSDictionary * responseObject))success
        failure:(void (^)(NSError *error))failure{
    
    if (_systemVersion >= 7.0) {
        [self.sessionManager POST:urlstring parameters:paragrams success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            failure(error);
        }];
    }else{
        [self.requestManager POST:urlstring parameters:paragrams success:^(AFHTTPRequestOperation *operation, id responseObject) {
            success(responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failure(error);
        }];
    }
}
@end
