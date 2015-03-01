//
//  FileSystemManager.m
//  AFNetworkingManager
//
//  Created by kaxiaoer on 15/2/28.
//  Copyright (c) 2015年 mgl. All rights reserved.
//

#import "FileSystemManager.h"
#import "AFSharedClient.h"

#define KplistDir @"plist"
#define KimgDir @"img"
#define KmoiveDir @"mov"

NSString * const leftMenuURL = @"http://115.28.208.210:8080/ishow/getmenu?userid=15050191718";
NSString * const resourceBaseURL = @"http://115.28.208.210:8080/ishow/attached/";

NSString * const leftMenuPlist = @"leftMenu.plist";
NSString * const allinfoPlist = @"allinfo.plist";

@interface FileSystemManager ()
@property (strong, nonatomic) NSMutableArray *leftMenu;
@property (strong, nonatomic) NSMutableArray *allInfo;
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableArray *movies;
@property (assign, nonatomic) NSUInteger finishedCount;

@property (assign, nonatomic) BOOL finished;
@end

@implementation FileSystemManager

+ (instancetype)sharedManager{
    static FileSystemManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[FileSystemManager alloc] init];
    });
    return shared;
}
- (instancetype)init{
    self = [super init];
    if (self) {
//TODO: create dir img,plist, mov
        NSString *docpath = documentPath(@"", KimgDir);
        BOOL dir = YES;
        BOOL create = [[NSFileManager defaultManager] fileExistsAtPath:docpath isDirectory:&dir];
        if (!create) {
            [[NSFileManager defaultManager] createDirectoryAtPath:docpath withIntermediateDirectories:NO attributes:nil error:nil];
            docpath = documentPath(@"", KplistDir);
            [[NSFileManager defaultManager] createDirectoryAtPath:docpath withIntermediateDirectories:NO attributes:nil error:nil];
            docpath = documentPath(@"", KmoiveDir);
            [[NSFileManager defaultManager] createDirectoryAtPath:docpath withIntermediateDirectories:NO attributes:nil error:nil];
        }

//        TODO: init ary
        NSMutableArray *leftMenu = [[NSMutableArray alloc] initWithCapacity:1];
        _leftMenu = leftMenu;
        
        NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:1];
        _images = images;
        
        NSMutableArray *movies = [[NSMutableArray alloc] initWithCapacity:1];
        _movies = movies;
        
        NSMutableArray *allInfo = [[NSMutableArray alloc] initWithCapacity:1];
        _allInfo = allInfo;
    }
    return self;
}

- (void)initLeftMenu{
    BOOL isExist = [[self class] isExistAtDocumentWithFileName:leftMenuPlist fileType:GLFileTypePlist];
    if (isExist) {
        NSString *path = documentPath(leftMenuPlist, KplistDir);
        NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:path];
        [self.leftMenu addObjectsFromArray:dic[@"data"]];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    [[AFSharedClient sharedManager] addGET:leftMenuURL paragrams:nil success:^(NSDictionary *responseObject) {
        NSLog([responseObject description],nil);
        [weakSelf.leftMenu addObjectsFromArray:responseObject[@"data"]];
        [[self class] writeToFileDirWithObject:responseObject fileName:leftMenuPlist fileType:GLFileTypePlist];
    } failure:^(NSError *error) {
        NSLog([error description],nil);
    }];
}
- (void)downloadImages{
    for (NSString *image in _images) {
        BOOL isExist = [[self class] isExistAtDocumentWithFileName:image fileType:GLFileTypeImage];
        if (isExist) {
            ++_finishedCount;
            if (_finishedCount == _images.count) {
                _finished = YES;
            }
            continue;
        }
        NSString *imagePath = [resourceBaseURL stringByAppendingString:image];
        [[AFSharedClient sharedManager] addGET:imagePath paragrams:nil success:^(NSDictionary *responseObject) {
            [[self class] writeToFileDirWithObject:responseObject fileName:image fileType:GLFileTypeImage];
            ++_finishedCount;
            if (_finishedCount == _images.count) {
                _finished = YES;
            }
        } failure:^(NSError *error) {
            NSLog([error description],nil);
        }];
    }
}
- (void)initImagesInfo{
    __weak __typeof(self) weakSelf = self;
    BOOL isExist = [[self class] isExistAtDocumentWithFileName:allinfoPlist fileType:GLFileTypePlist];
    if (isExist) {
        NSString *path = documentPath(allinfoPlist, KplistDir);
        NSDictionary *initDic = [[NSDictionary alloc] initWithContentsOfFile:path];
        NSArray *dataList = initDic[@"data"];
        [_allInfo addObjectsFromArray:dataList];
        for (NSDictionary *dic in dataList) {
            NSArray *categorylist = dic[@"categorylist"];
            for (NSDictionary *photo in categorylist) {
                NSArray *photolist = photo[@"photolist"];
                for (NSDictionary *res in photolist) {
                    NSString *imagename = res[@"photoname"];
                    if ([imagename containsString:@"."]) {
                        [weakSelf.images addObject:imagename];
                    }
                    
                    NSString *mov = res[@"videoname"];
                    if ([mov containsString:@"."]) {
                        [weakSelf.movies addObject:imagename];
                    }
                }
            }
        }
        [self downloadImages];
        return;
    }

    NSString *getSepratURL =  @"http://115.28.208.210:8080/ishow/getphoto?userid=15050191718&menuid=9";
//    @"http://115.28.208.210:8080/ishow/getphoto?userid=15011378789";
    
    [[AFSharedClient sharedManager] addGET:getSepratURL paragrams:nil success:^(NSDictionary *responseObject) {
        NSArray *dataList = responseObject[@"data"];
        [weakSelf.allInfo addObjectsFromArray:dataList];
        for (NSDictionary *dic in dataList) {
            NSArray *categorylist = dic[@"categorylist"];
            for (NSDictionary *photo in categorylist) {
                NSArray *photolist = photo[@"photolist"];
                for (NSDictionary *res in photolist) {
                    NSString *imagename = res[@"photoname"];
                    if ([imagename containsString:@"."]) {
                        [weakSelf.images addObject:imagename];
                    }
                    
                    NSString *mov = res[@"videoname"];
                    if ([mov containsString:@"."]) {
                        [weakSelf.movies addObject:imagename];
                    }
                }
            }
        }
        
        [weakSelf downloadImages];
        
        [FileSystemManager writeToFileDirWithObject:responseObject
                                           fileName:allinfoPlist
                                           fileType:GLFileTypePlist];
        
    } failure:^(NSError *error) {
        NSLog([error description],nil);
    }];
}
- (void)initSystem{
    [self initLeftMenu];
    [self initImagesInfo];
}

static inline NSString * documentPath(NSString *filename, NSString *dir){
    NSString *document = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    document = [document stringByAppendingPathComponent:dir];
    document = [document stringByAppendingPathComponent:filename];
    return document;
}

static inline NSString *typeDir(GLFileType type){
    NSString *dir = nil;
    switch (type) {
        case GLFileTypePlist:
            dir = KplistDir;
            break;
        case GLFileTypeImage:
            dir = KimgDir;
            break;
        case GLFileTypeMovie:
            dir = KmoiveDir;
            break;
        default:
            break;
    }
    return dir;
}

+ (void)writeToFileDirWithObject:(id)data fileName:(NSString *)fileName fileType:(GLFileType)type{
    NSString *dir = typeDir(type);
    NSString *path = documentPath(fileName, dir);
    NSLog(path,nil);
    BOOL responds = [data respondsToSelector:@selector(writeToFile:atomically:)];
    if (responds) {
        [data writeToFile:path atomically:NO];
    }
}
+ (BOOL)isExistAtDocumentWithFileName:(NSString *)filename fileType:(GLFileType)type{
    NSString *dir = typeDir(type);
    NSString *path = documentPath(filename, dir);
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:path];
    return exist;
}
- (NSArray *)relationInfoWithLeftMenuItem:(NSUInteger)index{
    NSDictionary *leftUnit = self.leftMenu[index];
    NSString *flag = leftUnit[@"id"];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.menuid = %@",flag];
    
    NSDictionary *resultDic = [[_allInfo filteredArrayUsingPredicate:predicate] firstObject];
    NSArray *result = resultDic[@"categorylist"];
    NSDictionary *all = @{@"categoryname":@"全部",@"photolist":[NSArray array]};
    NSMutableArray *mutA = [[NSMutableArray alloc] initWithArray:result];
    [mutA insertObject:all atIndex:0];
    return result;
}
- (NSArray *)relationInfoWithObject:(NSArray *)inputAry withName:(NSString *)name{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.categoryname = %@",name];
    NSDictionary *resultDic = [[inputAry filteredArrayUsingPredicate:predicate] firstObject];
    NSArray *result = resultDic[@"photolist"];
    return result;
}
+ (NSString *)imagePathWithName:(NSString *)imageName{
    return documentPath(imageName, KimgDir);
}
@end
