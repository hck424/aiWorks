//
//  SysInfo.m
//  aiWorks
//
//  Created by 김학철 on 2020/03/05.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "SysInfo.h"

@implementation SysInfo
+ (NSString *)getCurrentVersion {
    NSString *version = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return version;
}
+ (NSString *)getBundleName {
    return [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleDisplayName"];
}
+ (NSString *)getBundleIdentifier {
    return [[NSBundle mainBundle] bundleIdentifier];
}

+ (BOOL)isUpdatable:(NSString *)newVersion {
    NSArray *arrCur = [[SysInfo getCurrentVersion] componentsSeparatedByString:@"."];
    NSArray *arrNew = [newVersion componentsSeparatedByString:@"."];
    
    for (NSInteger i = 0; i < arrCur.count; i++) {
        NSString *curStr = [arrCur objectAtIndex:i];
        NSString *newStr = @"0";
        if (i < arrNew.count) {
            newStr = [arrNew objectAtIndex:i];
        }
        if ([newStr integerValue] > [curStr integerValue]) {
            return YES;
        }
    }
    return NO;
}
@end
