//
//  CameraManager.swift
//  R&D-LicenceScanner
//
//  Created by Pavel Boryseiko on 17/8/18.
//  Copyright © 2018 GRIDSTONE. All rights reserved.
//

import UIKit
import AVFoundation

public class CameraManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var finishPickingClosure: ((UIImage) -> ())?

    func pickerController() -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera

        return pickerController
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        var originalImage: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        switch originalImage.imageOrientation {
        case .right:
            originalImage = originalImage.rotatedByDegrees(deg: 90)
        case .down:
            originalImage = originalImage.rotatedByDegrees(deg: 180)
        case .left:
            originalImage = originalImage.rotatedByDegrees(deg: -90)
        default:
            break
        }

        finishPickingClosure?(originalImage)
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UIImage {

    func rotateForCorrectOrientation() -> UIImage {

        var image = self

        switch imageOrientation {
        case .right:
            image = image.rotatedByDegrees(deg: 90)
        case .down:
            image = image.rotatedByDegrees(deg: 180)
        case .left:
            image = image.rotatedByDegrees(deg: -90)
        default:
            break
        }

        return image
    }

    func rotatedByDegrees(deg degrees: CGFloat) -> UIImage {
        let origin = CGPoint(x: 0, y: 0)

        let oldImage = self
        let oldSize = CGSize(width: oldImage.cgImage!.width, height: oldImage.cgImage!.height)
        let oldRect = CGRect(origin: origin, size: oldSize)
        let radians = degrees * CGFloat(Double.pi / 180)
        let adjustedRadians = (90 - degrees) * CGFloat(Double.pi / 180)

        let height = abs(oldSize.width * sin(radians) + oldSize.height * sin(adjustedRadians))
        let width = abs(oldSize.width * cos(radians) + oldSize.height * cos(adjustedRadians))

        let newSize = CGSize(width: width, height: height)
        let maxSize = CGSize(width: max(width, height), height: max(width, height))

        UIGraphicsBeginImageContext(maxSize)

        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        bitmap.translateBy(x: maxSize.width / 2, y: maxSize.height / 2)
        bitmap.rotate(by: radians)
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.translateBy(x: -maxSize.width / 2, y: -maxSize.height / 2)

        let newRect = CGRect(origin: origin, size: newSize)
        bitmap.draw(oldImage.cgImage!, in: oldRect)

        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!

        UIGraphicsEndImageContext()

        let cgImage = newImage.cgImage
        let imageRef: CGImage = cgImage!.cropping(to: newRect)!
        let croppedImage: UIImage = UIImage(cgImage: imageRef, scale: 1.0, orientation: newImage.imageOrientation)

        return croppedImage
    }
}
