//
//  FileSystemManager.h
//  AFNetworkingManager
//
//  Created by kaxiaoer on 15/2/28.
//  Copyright (c) 2015年 mgl. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, GLFileType){
    GLFileTypePlist,
    GLFileTypeImage,
    GLFileTypeMovie,
};

@interface FileSystemManager : NSObject
+ (instancetype)sharedManager;
- (void)initSystem;

+ (void)writeToFileDirWithObject:(id)data fileName:(NSString *)fileName fileType:(GLFileType)type;
+ (BOOL)isExistAtDocumentWithFileName:(NSString *)filename fileType:(GLFileType)type;

@end