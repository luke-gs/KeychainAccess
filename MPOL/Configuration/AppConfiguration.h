//
//  AppConfiguration.h
//  MPOL
//
//  Created by Bryan Hathaway on 19/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//
#import <Foundation/Foundation.h>

// This header uses Preprocessor Definitions as defined in our xcconfigs and maps them to static strings so they are available to swift.

/// The server endpoint
static const NSString * APP_HOST_URL = CONFIG_HOST_URL;
static const NSString * CAD_APP_SCHEME = CAD_URL_TYPE_SCHEME;
static const NSString * HOCKEY_APP_IDENTIFIER = CONFIG_HOCKEY_APP_IDENTIFIER;
static const NSString * HOCKEY_SECRET = CONFIG_HOCKEY_SECRET;
