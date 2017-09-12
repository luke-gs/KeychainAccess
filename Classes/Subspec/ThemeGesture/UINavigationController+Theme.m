//
//  UINavigationController+Theme.m
//  MPOLKit
//
//  Created by KGWH78 on 12/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

#import "UINavigationController+Theme.h"
#import <MPOLKit/MPOLKit-Swift.h>

@import UIKit;
@import ObjectiveC.runtime;


@implementation UINavigationController (Theme)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector = @selector(viewDidLoad);
        SEL swizzledSelector = @selector(swizzled_viewDidLoad);

        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        BOOL didAddMethod = class_addMethod(
                                            class,
                                            originalSelector,
                                            method_getImplementation(swizzledMethod),
                                            method_getTypeEncoding(swizzledMethod)
                                            );
        if (didAddMethod) {
            class_replaceMethod(
                                class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod)
                                );
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)swizzled_viewDidLoad {
    [self swizzled_viewDidLoad];

    UITapGestureRecognizer *tripleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeTheme:)];
    tripleTapRecognizer.numberOfTouchesRequired = 1;
    tripleTapRecognizer.numberOfTapsRequired = 3;
    tripleTapRecognizer.cancelsTouchesInView = NO;
    tripleTapRecognizer.delegate = self;
    [self.navigationBar addGestureRecognizer:tripleTapRecognizer];

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (([touch.view isKindOfClass:[UIButton class]] || [touch.view isKindOfClass:[UINavigationItem class]] ||
         [touch.view isKindOfClass:[UIBarItem class]] || [touch.view isKindOfClass:[UIControl class]])) {
        return NO;
    } else {
        CGPoint point = [touch locationInView:touch.view];
        UINavigationBar *navigationBar = (UINavigationBar *)touch.view;
        Class navigationItemViewClass = NSClassFromString(@"UINavigationItemButtonView");
        for (UIView* subview in navigationBar.subviews) {
            if (([subview isKindOfClass:[UIControl class]] ||
                 [subview isKindOfClass:navigationItemViewClass]) && CGRectContainsPoint(CGRectInset(subview.frame, -16, -16), point)) {
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)changeTheme:(id)recognizer {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ThemeManager* manager = [ThemeManager shared];
        [manager setCurrentInterfaceStyle: manager.currentInterfaceStyle == UserInterfaceStyleDark ? UserInterfaceStyleLight : UserInterfaceStyleDark];
    });
}


@end
