//
//  LOTAnimationView+MPOLAnimationStyle.swift
//  MPOLKit
//
//  Created by KGWH78 on 3/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import Lottie


public extension LOTAnimationView {
    
    /// Preload MPOL animations
    static func preloadMPOLAnimations() {
        let urls: [URL] = [MPOLSpinnerView.fileURL]
        
        DispatchQueue.global().async {
            urls.forEach { (url) in
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

