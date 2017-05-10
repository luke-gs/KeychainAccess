//
//  UIImage+StatusDot.swift
//  MPOLKit
//
//  Created by Rod Brown on 28/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

extension UIImage {
    
    internal static let statusDotFrameSize = CGSize(width: 24.0, height: 24.0)
    
    @available(iOS 10, *)
    private static let statusDotGenerator = UIGraphicsImageRenderer(size: statusDotFrameSize)
    
    public class func statusDot(withColor color: UIColor) -> UIImage {
        
        func drawDot(in context: CGContext) {
            context.setFillColor(color.cgColor)
            context.addEllipse(in: CGRect(x: 3.0, y: 3.0, width: statusDotFrameSize.width - 6.0, height: statusDotFrameSize.height - 6.0))
            context.fillPath()
        }
        
        if #available(iOS 10, *) {
            return statusDotGenerator.image { drawDot(in: $0.cgContext) }
        } else {
            UIGraphicsBeginImageContextWithOptions(statusDotFrameSize, false, 0.0)
            defer { UIGraphicsEndImageContext() }
            
            if let context = UIGraphicsGetCurrentContext() {
                drawDot(in: context)
            }
            
            return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        }
    }
    
}
