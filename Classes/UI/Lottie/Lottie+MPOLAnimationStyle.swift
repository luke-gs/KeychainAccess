//
//  LOTAnimationView+MPOLAnimationStyle.swift
//  MPOLKit
//
//  Created by KGWH78 on 3/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Lottie

/// MPOL supported animation style to used with LOTAnimationView.
///
/// The resource files are guaranteed to be in the lottie directory.
public enum MPLAnimationStyle {
    case spinner
}

private let LottieDirectory = "lottie"
private let LottieType      = "json"

public extension LOTAnimationView {
    
    /// Create an animation with specific style.
    ///
    /// - Parameters:
    ///   - style: The style of the animation.
    /// - Returns: A preconfigured LOTAnimationView
    static func animation(style: MPLAnimationStyle) -> LOTAnimationView {
        let bundle = Bundle.mpolKit
    
        let view: LOTAnimationView
        
        switch style {
        case .spinner:
            view = LOTAnimationView(filePath: bundle.path(forResource: "spinner", ofType: LottieType, inDirectory: LottieDirectory)!)
            view.loopAnimation = true
        }
        
        return view
    }
 
}
