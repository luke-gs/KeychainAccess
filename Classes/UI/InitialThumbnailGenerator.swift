//
//  InitialThumbnailGenerator.swift
//  MPOLKit
//
//  Created by Rod Brown on 23/5/17.
//
//

import UIKit

// TEMPORARY: This is a massive hack.

private let initialThumbnailSize = CGSize(width: 200.0, height: 200.0)

@available(iOS 10, *)
private let sharedRenderer = UIGraphicsImageRenderer(size: initialThumbnailSize)

func generateThumbnail(forInitials initials: String) -> UIImage {
    func drawText() {
        if initials.isEmpty { return }
        
        let initialString = initials as NSString
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 90.0, weight: UIFontWeightLight)]
        let screenScale = UIScreen.main.scale
        
        let textSize = initialString.size(attributes: attributes)
        
        let originPoint = CGPoint(x: ((initialThumbnailSize.width - textSize.width) / 2.0).rounded(toScale: screenScale), y: ((initialThumbnailSize.height - textSize.height) / 2.0).rounded(toScale: screenScale))
        
        (initials as NSString).draw(at: originPoint, withAttributes: attributes)
    }
    
    if #available(iOS 10, *) {
        return sharedRenderer.image(actions: { _ in drawText() }).withRenderingMode(.alwaysTemplate)
    } else {
        UIGraphicsBeginImageContextWithOptions(initialThumbnailSize, false, 0.0)
        drawText()
        let image = UIGraphicsGetImageFromCurrentImageContext()!.withRenderingMode(.alwaysTemplate)
        UIGraphicsEndImageContext()
        return image
    }
    
}
