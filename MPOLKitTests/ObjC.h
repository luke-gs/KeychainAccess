//
//  ObjC.h
//  MPOLKitTests
//
//  Created by Trent Fitzgibbon on 15/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Class for Objective C utility methods
@interface ObjC : NSObject

/// Utility method to call a block that may throw an NSException, and convert it to a Swift Error
+ (BOOL)catchException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error;

@end
