//
//  UITextView+Notifications.m
//  MPOLKit
//
//  Created by Rod Brown on 4/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

#import <objc/runtime.h>
#import "UITextView+Notifications.h"


NSNotificationName const MPOL_UITextFieldTextWillBeginEditingNotification = @"MPOL_UITextViewTextWillBeginEditingNotification";

@implementation UITextView (Notifications)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(becomeFirstResponder);
        SEL swizzledSelector = @selector(mpol_becomeFirstResponder);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (BOOL)mpol_becomeFirstResponder {
    if ([self canBecomeFirstResponder] && [self isFirstResponder] == NO) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MPOL_UITextFieldTextWillBeginEditingNotification object:self];
    }
    
    return [self mpol_becomeFirstResponder];
}

@end
