//
//  UITextView+NotificationWorkaround.h
//  MPOLKit
//
//  Created by Rod Brown on 4/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

#import <UIKit/UIKit.h>

/// WORKAROUND:
///
/// UITextView and UITextField both fire "Did Begin Editing" notifications.
/// We use the UITextField notification to adjust the inputAccessoryView just
/// before the keyboard is presented. UITextView however invokes the keyboard
/// prior to the UITextViewTextDidBeginEditing notification, breaking this
/// technique.
///
/// The workaround is to method swizzle the becomeFirstResponder method to
/// fire a notification just prior to becoming first responder.

/// A notification fired when a UITextView is about to become first responder
NSNotificationName const MPOL_UITextFieldTextWillBeginEditingNotification;

@interface UITextView (NotificationWorkaround)

@end
