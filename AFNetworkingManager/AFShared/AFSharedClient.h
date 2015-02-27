//
//  AFSharedClient.h
//  AFNetworking iOS Example
//
//  Created by family on 15/2/27.
//  Copyright (c) 2015年 Gowalla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperationManager.h"
#import <UIKit/UIKit.h>

@interface AFSharedClient : NSObject
+ (instancetype)sharedManager;

- (void)addPOST:(NSString *)urlstring
      paragrams:(NSDictionary *)paragrams
        success:(void (^)(NSDictionary * responseObject))success
        failure:(void (^)(NSError *error))failure;
@end
