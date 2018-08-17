//
//  UIImage+Initials.swift
//  MPOLKit
//
//  Created by Rod Brown on 25/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


// Temporary. Should be refactored into a ThumbnailGenerator

private let initialThumbnailSize = CGSize(width: 200.0, height: 200.0)

extension UIImage {
    
    private static let thumbnailRenderer = UIGraphicsImageRenderer(size: initialThumbnailSize)
    
    public class func thumbnail(withInitials initials: String) -> UIImage {
        return thumbnailRenderer.image { _ in
            if initials.isEmpty { return }
            
            let initialString = initials as NSString
            let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 90.0, weight: UIFont.Weight.light)]
            let screenScale = UIScreen.main.scale
            
            let textSize = initialString.size(withAttributes: attributes)
            let originPoint = CGPoint(x: ((initialThumbnailSize.width - textSize.width) / 2.0).rounded(toScale: screenScale),
                                      y: ((initialThumbnailSize.height - textSize.height) / 2.0).rounded(toScale: screenScale))
            
            UIColor(white: 0.2, alpha: 1.0).set()
            initialString.draw(at: originPoint, withAttributes: attributes)
        }
    }
    
}
