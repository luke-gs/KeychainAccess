//
//  UIView+JiggleAnimation.swift
//  MPOLKit
//
//  Created by QHMW64 on 25/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Any UIView is able to "shake", which will cause the view to slightly jiggle
/// in position, drawing attention that something has occurred
internal extension UIView {
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.06
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: frame.midX, y: frame.midY - 3)
        animation.toValue = CGPoint(x: frame.midX, y: frame.midY + 3)
        layer.add(animation, forKey: "position")
    }
}
