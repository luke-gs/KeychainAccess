#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MPOLKit.h"
#import "UITextView+NotificationWorkaround.h"

FOUNDATION_EXPORT double MPOLKitVersionNumber;
FOUNDATION_EXPORT const unsigned char MPOLKitVersionString[];

