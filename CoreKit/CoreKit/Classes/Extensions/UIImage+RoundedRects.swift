//
//  UIImage+RoundedRects.swift
//  MPOLKit
//
//  Created by Rod Brown on 7/05/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

public extension UIImage {
    
    public class func roundedImage(size: CGSize, cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor?, fillColor: UIColor?) -> UIImage {
        precondition(borderColor != nil || fillColor != nil, "UIImage.roundedImage(size: cornerRadius: borderWidth: borderColor: fillColor:) requires a fill or border color, or both.")
        precondition(borderWidth >=~ 0.0, "'borderWidth' parameter must be a positive number or zero.")
        precondition(cornerRadius >=~ 0.0 && cornerRadius <=~ size.width / 2.0 && cornerRadius <=~ size.height / 2.0, "'cornerRadius` parameter must be a positive number or zero, and less than or equal to half both the width and height of the size.")
        
        let imageSize = CGSize(width: ceil(size.width), height: ceil(size.height))
        return UIGraphicsImageRenderer(size: imageSize).image { _ in
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
    }
    
    public class func resizableRoundedImage(cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor?, fillColor: UIColor?) -> UIImage {
        let side = ceil(cornerRadius * 2.0 + 5.0 + borderWidth)
        let image = roundedImage(size: CGSize(width: side, height: side), cornerRadius: cornerRadius, borderWidth: borderWidth, borderColor: borderColor, fillColor: fillColor)
        let inset = floor(side / 2.0 - 1.0)
        return image.resizableImage(withCapInsets: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset), resizingMode: .stretch)
    }
    
    public enum CircleBackgroundSizingStyle {
        /// Using padding size to create the image size
        /// - Parameters:
        ///   - padding: the size of the padding to use
        ///   - shrinkImage: whether to maintain the original image size and shrink the image to fit in the circle, otherwise grow the circle
        case auto(padding: CGSize, shrinkImage: Bool)
        
        /// Use a fixed circle size
        /// - Parameters:
        ///   - size: the size to use for the circle frame
        ///   - padding: the size of the padding to use
        case fixed(size: CGSize, padding: CGSize)
    }
    
    /// Creates an image with a circle background behind the existing image
    ///
    /// - Parameters:
    ///   - tintColor: color to tint the image
    ///   - circleColor: the fill color of the circle
    ///   - style: the sizing style to use
    ///   - shouldCenterImage: whether to center the image in the circle. This will override positioning set by the padding and the default is `true`
    public func withCircleBackground(tintColor: UIColor?, circleColor: UIColor?, style: CircleBackgroundSizingStyle, shouldCenterImage: Bool = true) -> UIImage? {
        let circleColor = circleColor ?? .clear
        
        // Prepare circle sizing
        var circleSize: CGSize = .zero
        var padding: CGSize = .zero
        var shrinkImage: Bool = false
        
        if case let CircleBackgroundSizingStyle.auto(_padding, _shrinkImage) = style {
            padding = _padding
            shrinkImage = _shrinkImage
            
            if shrinkImage {
                circleSize = self.size
            } else {
                circleSize = CGSize(width: self.size.width + padding.width, height: self.size.height + padding.height)
            }
        } else if case let CircleBackgroundSizingStyle.fixed(size, _padding) = style {
            circleSize = size
            padding = _padding
            shrinkImage = true
        }
        
        // Make the circle even (i.e. not an oval)
        let largestSide = max(circleSize.width, circleSize.height)
        
        // Create the circle image
        let circle = UIImage.roundedImage(size: CGSize(width: largestSide, height: largestSide),
                                          cornerRadius: largestSide / 2,
                                          borderWidth: 0,
                                          borderColor: nil,
                                          fillColor: circleColor)

        var image: UIImage = self
        
        // Tint if argument was provided
        if let tintColor = tintColor {
            let tintedImage = UIGraphicsImageRenderer(size: self.size).image { _ in
                tintColor.setFill()
                image = self.withRenderingMode(.alwaysTemplate)
                image.draw(at: .zero, blendMode: .colorBurn, alpha: 1.0)
            }
            image = tintedImage
        }
        
        UIGraphicsBeginImageContextWithOptions(circle.size, false, 0)
        
        // Prepare rect sizing
        let circleRect: CGRect = CGRect(x: 0,
                                        y: 0,
                                        width: circle.size.width,
                                        height: circle.size.height)
        let imageRect: CGRect
        
        let paddedX = padding.width / 2
        let paddedY = padding.height / 2
        let centeredX: CGFloat
        let centeredY: CGFloat
        
        
        let imageSize: CGSize
        
        if shrinkImage {
            var widthRatio: CGFloat = 1
            var heightRatio: CGFloat = 1
            
            // Manage non-square images
            if image.size.width < image.size.height {
                widthRatio = image.size.width / image.size.height
            } else if image.size.height < image.size.width {
                heightRatio = image.size.height / image.size.width
            }
            
            let width = circle.size.width * widthRatio
            let height = circle.size.height * heightRatio
            let paddingWidth = padding.width * widthRatio
            let paddingHeight = padding.height * heightRatio
            
            // Determine the new size for drawing the image
            let newSize = CGSize(width: width - paddingWidth,
                                 height: height - paddingHeight)
            
            // Get the center
            centeredX = circleRect.size.width / 2  - newSize.width / 2
            centeredY = circleRect.size.height / 2 - newSize.height / 2
            
            // Pad on equally on both sides, leave image size as-is
            imageSize = newSize
        } else {
            // Get the center
            centeredX = (circleRect.size.width / 2) - (image.size.width / 2)
            centeredY = (circleRect.size.height / 2) - (image.size.height / 2)
            
            // Pad on both sides, leave image size as-is
            imageSize = image.size
        }
        
        imageRect = CGRect(x: shouldCenterImage ? centeredX : paddedX,
                           y: shouldCenterImage ? centeredY : paddedY,
                           width: imageSize.width,
                           height: imageSize.height)
        
        // Draw the circle first
        circle.draw(in: circleRect)
        
        // Then draw the image over the top
        image.draw(in: imageRect)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    public func overlayed(with image: UIImage, offset: CGPoint) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        
        let selfRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: selfRect)
        
        let midPoint = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        
        let imageRect = CGRect(x: midPoint.x + offset.x, y: midPoint.y + offset.y, width: image.size.width, height: image.size.height)
        image.draw(in: imageRect)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result

    }
}
