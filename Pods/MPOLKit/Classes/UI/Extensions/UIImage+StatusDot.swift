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
    
    public class func statusDot(withColor color: UIColor) -> UIImage {
        return statusDotGenerator.image {
            let context = $0.cgContext
            context.setFillColor(color.cgColor)
            context.addEllipse(in: CGRect(x: 3.0, y: 3.0, width: statusDotFrameSize.width - 6.0, height: statusDotFrameSize.height - 6.0))
            context.fillPath()
        }
    }
    
}
