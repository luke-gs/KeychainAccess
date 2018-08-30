//
//  UIImage+Resizing.swift
//  Alamofire
//
//  Created by Valery Shorinov on 5/10/17.
//

import Foundation

extension UIImage{
    public func resizeImageWith(newSize: CGSize, retainAspect: Bool = false, renderMode: UIImageRenderingMode = .automatic) -> UIImage {
        
        var newWidth = newSize.width
        var newHeight = newSize.height
        
        if retainAspect == true {
            let horizontalRatio = newSize.width / size.width
            let verticalRatio = newSize.height / size.height
            let ratio = max(horizontalRatio, verticalRatio)
            newWidth = size.width * ratio
            newHeight = size.height * ratio
        }
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, scale)
        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!.withRenderingMode(renderMode)
    }
}
