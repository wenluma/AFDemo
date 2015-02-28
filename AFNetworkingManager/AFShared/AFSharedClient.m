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
            
            AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
            jsonSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"image/jpeg", nil];
            
            AFHTTPResponseSerializer *serialier = [AFHTTPResponseSerializer serializer];
            
            
            NSArray *comSerializers = @[jsonSerializer,serialier];
            AFCompoundResponseSerializer *comResponser = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:comSerializers];
            
            self.sessionManager.responseSerializer = comResponser;
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

- (void)addGET:(NSString *)urlstring
     paragrams:(NSDictionary *)paragrams
       success:(void (^)(NSDictionary * responseObject))success
       failure:(void (^)(NSError *error))failure{
    
    if (_systemVersion >= 7.0) {
        [self.sessionManager GET:urlstring parameters:paragrams success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            failure(error);
        }];
    }else{
        [self.requestManager GET:urlstring parameters:paragrams success:^(AFHTTPRequestOperation *operation, id responseObject) {
            success(responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failure(error);
        }];
    }
}

- (void)downLoadResource:(NSString *)resourceURL cachedDirectory:(NSString *)directoryPath{
    
    [[AFSharedClient sharedManager] addGET:resourceURL paragrams:nil success:^(NSDictionary *responseObject) {
        if([responseObject isKindOfClass:[NSData class]]){
            UIImage *image = [UIImage imageWithData:(NSData *)responseObject];
        }
    } failure:^(NSError *error) {
        NSLog([error description],nil);
    }];
}

@end
