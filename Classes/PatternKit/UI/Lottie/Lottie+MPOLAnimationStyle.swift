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
        
        /// Preload all animations on a background thread
        DispatchQueue.global().async {
            urls.forEach { (url) in
                _ = loadMPOLAnimation(fileURL: url)
            }
        }
    }

    /// Load an animation synchronously
    static func loadMPOLAnimation(fileURL: URL) -> LOTComposition? {
        let data = try! Data(contentsOf: fileURL)
        if let json = try! JSONSerialization.jsonObject(with: data) as? [AnyHashable: Any] {
            let composition = LOTComposition(json: json, withAssetBundle: Bundle.mpolKit)
            DispatchQueue.main.async {
                LOTAnimationCache.shared().addAnimation(composition, forKey: fileURL.absoluteString)
            }
            return composition
        }
        return nil
    }
}

