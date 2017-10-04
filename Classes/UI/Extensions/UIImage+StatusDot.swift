//
//  UIImage+StatusDot.swift
//  MPOLKit
//
//  Created by Rod Brown on 28/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

extension UIImage {
    
    public static let statusDotFrameSize = CGSize(width: 24.0, height: 24.0) // TODO: This needs a refactor
    
    private static let statusDotGenerator = UIGraphicsImageRenderer(size: statusDotFrameSize)
    
    public class func statusDot(withColor color: UIColor, strokeColor: UIColor = .clear) -> UIImage {
        return statusDotGenerator.image {
            let context = $0.cgContext
            context.addEllipse(in: CGRect(x: 3.0, y: 3.0, width: statusDotFrameSize.width - 6.0, height: statusDotFrameSize.height - 6.0))
            context.setFillColor(color.cgColor)
            if strokeColor != .clear {
                // Stroke and fill
                context.setStrokeColor(strokeColor.cgColor)
                context.setLineWidth(2)
                context.drawPath(using: .fillStroke)
            } else {
                // Just fill
                context.fillPath()
            }
        }
    }
    
}
