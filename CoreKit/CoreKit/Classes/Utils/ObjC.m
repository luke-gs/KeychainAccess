//
//  ObjC.m
//  MPOLKitTests
//
//  Created by Trent Fitzgibbon on 15/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

#import "ObjC.h"

@implementation ObjC

/// Utility method to call a block that may throw an NSException, and convert it to a Swift Error
+ (BOOL)catchException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error {
    @try {
        tryBlock();
        return YES;
    }
    @catch (NSException *exception) {
        *error = [[NSError alloc] initWithDomain:exception.name code:0 userInfo:exception.userInfo];
        return NO;
    }
}

@end
