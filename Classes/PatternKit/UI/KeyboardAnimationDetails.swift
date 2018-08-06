//
//  KeyboardAnimationDetails.swift
//  MPOLKit
//
//  Created by Rod Brown on 12/4/17.
//
//

import UIKit


public struct KeyboardAnimationDetails {
    public let startFrame: CGRect
    public let endFrame: CGRect
    public let duration: TimeInterval
    public let curve: UIViewAnimationOptions
}

public extension Notification {
    
    /// Returns the keyboard animation details from the notification, if it is a keyboard update notification.
    public func keyboardAnimationDetails() -> KeyboardAnimationDetails? {
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
