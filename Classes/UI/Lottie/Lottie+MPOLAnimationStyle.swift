//
//  LOTAnimationView+MPOLAnimationStyle.swift
//  MPOLKit
//
//  Created by KGWH78 on 3/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import Lottie


protocol MPOLAnimatable {
    static var fileURL: URL { get }
}

public extension LOTAnimationView {
    
    /// Preload MPOL animations
    static func preloadMPOLAnimations() {
        let animations: [MPOLAnimatable.Type] = [MPOLSpinnerView.self]
        
        DispatchQueue.global().async {
            animations.forEach { (animation) in
                let url = animation.fileURL
                
                let data = try! Data(contentsOf: url)
                if let json = try! JSONSerialization.jsonObject(with: data) as? [AnyHashable: Any] {
                    let composition = LOTComposition(json: json, withAssetBundle: Bundle.mpolKit)
                    
                    DispatchQueue.main.async {
                        LOTAnimationCache.shared().addAnimation(composition!, forKey: url.absoluteString)
                    }
                }
            }
        }
    }

}

