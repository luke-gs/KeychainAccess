//
//  UIImage+RoundedRects.swift
//  MPOL
//
//  Created by Rod Brown on 7/05/2016.
//  Copyright © 2016 RodBrown. All rights reserved.
//

import UIKit

public extension UIImage {
    
    public class func roundedImage(size: CGSize, cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor?, fillColor: UIColor?) -> UIImage {
        precondition(borderColor != nil || fillColor != nil, "UIImage.roundedImage(size: cornerRadius: borderWidth: borderColor: fillColor:) requires a fill or border color, or both.")
        precondition(borderWidth >= 0.0, "'borderWidth' parameter must be a positive number or zero.")
        precondition(cornerRadius >= 0.0 && cornerRadius <= size.width / 2.0 && cornerRadius <= size.height / 2.0, "'cornerRadius` parameter must be a positive number or zero, and less than or equal to half both the width and height of the size.")
        
        let imageSize = CGSize(width: ceil(size.width), height: ceil(size.height))
        
        func drawImage() {
            let bezierPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size).insetBy(dx: borderWidth / 2.0, dy: borderWidth / 2.0), cornerRadius: cornerRadius)
            bezierPath.lineWidth = borderWidth
            
            if let fillColor = fillColor {
                fillColor.setFill()
                bezierPath.fill()
            }
            if let strokeColor = borderColor {
                strokeColor.setStroke()
                bezierPath.stroke()
            }
        }
        
        if #available(iOS 10, *) {
            let imageRenderer = UIGraphicsImageRenderer(size: imageSize)
            return imageRenderer.image { (_: UIGraphicsImageRendererContext) in drawImage() }
        } else {
            UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
            drawImage()
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image ?? UIImage()
        }
    }
    
    public class func resizableRoundedImage(cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor?, fillColor: UIColor?) -> UIImage {
        let side = ceil(cornerRadius * 2.0 + 5.0 + borderWidth)
        let image = roundedImage(size: CGSize(width: side, height: side), cornerRadius: cornerRadius, borderWidth: borderWidth, borderColor: borderColor, fillColor: fillColor)
        let inset = floor(side / 2.0 - 1.0)
        return image.resizableImage(withCapInsets: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset), resizingMode: .stretch)
    }
}
