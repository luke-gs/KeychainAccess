//
//  InitialThumbnailGenerator.swift
//  MPOLKit
//
//  Created by Rod Brown on 23/5/17.
//
//

import UIKit

// TEMPORARY: This is a massive hack.

@available(iOS 10, *)
private let sharedRenderer = UIGraphicsImageRenderer(size: CGSize(width: 200.0, height: 200.0))

func generateInitialThumbnail(initials: String) -> UIImage {
    
    func drawText() {
        (initials as NSString).draw(at: CGPoint(x: 47, y: 45), withAttributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 90.0, weight: UIFontWeightLight)])
    }
    
    if #available(iOS 10, *) {
        return sharedRenderer.image(actions: { _ in drawText() }).withRenderingMode(.alwaysTemplate)
    } else {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 200.0, height: 200.0), false, 0.0)
        drawText()
        let image = UIGraphicsGetImageFromCurrentImageContext()!.withRenderingMode(.alwaysTemplate)
        UIGraphicsEndImageContext()
        return image
    }
    
}
