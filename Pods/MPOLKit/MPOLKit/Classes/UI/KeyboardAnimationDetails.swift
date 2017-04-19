//
//  KeyboardAnimationDetails.swift
//  MPOLKit
//
//  Created by Rod Brown on 12/4/17.
//
//

import UIKit


internal struct KeyboardAnimationDetails {
    let startFrame: CGRect
    let endFrame: CGRect
    let duration: TimeInterval
    let curve: UIViewAnimationOptions
}

internal extension Notification {
    
    /// Returns the keyboard animation details from the notification, if it is a keyboard update notification.
    func keyboardAnimationDetails() -> KeyboardAnimationDetails? {
        guard let userInfo = self.userInfo,
            let startFrame = userInfo[UIKeyboardFrameBeginUserInfoKey] as? CGRect,
            let endframe   = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect,
            let duration   = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return nil }
        
        let animationCurve: UIViewAnimationOptions
        if let curveInt = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int,
            let curve = UIViewAnimationCurve(rawValue: curveInt) {
            animationCurve = curve.animationOption
        } else {
            animationCurve = .curveEaseInOut
        }
        
        return KeyboardAnimationDetails(startFrame: startFrame, endFrame: endframe, duration: duration, curve: animationCurve)
    }
    
}
