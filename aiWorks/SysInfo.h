//
//  SysInfo.h
//  aiWorks
//
//  Created by 김학철 on 2020/03/05.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SysInfo : NSObject
+ (NSString *)getCurrentVersion;
+ (NSString *)getBundleName;
+ (NSString *)getBundleIdentifier;
+ (BOOL)isUpdatable:(NSString *)newVersion;
@end

NS_ASSUME_NONNULL_END
