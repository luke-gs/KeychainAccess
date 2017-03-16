//
//  UITextView+NotificationWorkaround.m
//  MPOLKit
//
//  Created by Rod Brown on 4/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

#import "UITextView+NotificationWorkaround.h"
#import <objc/runtime.h>


NSNotificationName const MPOL_UITextFieldTextWillBeginEditingNotification = @"MPOL_UITextViewTextWillBeginEditingNotification";

@implementation UITextView (NotificationWorkaround)

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
    
    // We only fire the "will begin" notification iff:
    //    1) The field isn't first responder,
    //    2) It can become first responder (checks the delgate), and
    //    3) The current window doesn't have a first responder, or it successfully resigned first responder.
    // This is the same set of checks that determine if it will be successful.
    if ([self isFirstResponder] == NO && [self canBecomeFirstResponder] && [[self window] endEditing:NO]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MPOL_UITextFieldTextWillBeginEditingNotification object:self];
    }
    
    return [self mpol_becomeFirstResponder];
}

@end
