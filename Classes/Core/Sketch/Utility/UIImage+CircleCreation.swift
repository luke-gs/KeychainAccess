//
//  UIImage+CircleCreation.swift
//  MPOLKit
//
//  Created by QHMW64 on 25/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public extension UIImage {


    /// Returns an image of a circle of a certain diameter and color
    ///
    /// - Parameters:
    ///   - diameter: The diameter of the circle
    ///   - color: The color to draw the circle
    /// - Returns: An image of a circle
    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()

        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)

        ctx.restoreGState()
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }

    /// Overlay the image with given color
    /// white will stay white and black will stay black as the lightness of the image is preserved
    func overlayed(with color: UIColor) -> UIImage? {

        return modifiedImage { context, rect in

            context.setBlendMode(.overlay)
            color.setFill()
            context.fill(rect)

            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }
    
    /// Put an image on a circle.
    /// Might break if diameter is smaller than size.width or size.height.
    func surroundWithCircle(diameter: CGFloat, color: UIColor) -> UIImage {
        let size = CGSize(width: diameter, height: diameter)
        let circle = UIImage.circle(diameter: diameter, color: color)
        
        // compose icon and coloured circle
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        circle.draw(at: CGPoint(x: 0, y: 0))
        self.draw(at: CGPoint(x: (size.width - self.size.width) / 2, y: (size.height - self.size.height) / 2))
        let surroundedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return surroundedImage
    }

    private func modifiedImage( draw: (CGContext, CGRect) -> ()) -> UIImage? {

        // using scale correctly preserves retina images
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext = UIGraphicsGetCurrentContext()!

        // correctly rotate image
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)

        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)

        draw(context, rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}
