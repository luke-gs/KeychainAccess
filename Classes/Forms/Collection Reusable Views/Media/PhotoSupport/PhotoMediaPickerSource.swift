//
//  PhotoMediaPickerSource.swift
//  MPOLKit
//
//  Created by KGWH78 on 16/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


/// A protocol that defines an input source for choosing an image
public protocol PhotoMediaPickerSource: class {

    /// The title that will be displayed as an option.
    var title: String { get }

    /// Call this closure to save the image.
    var savePhotoMedia: ((UIImage) -> ())? { get set }

    /// The view controller to be presented.
    func viewController() -> UIViewController

}


/// Choose image from camera
public class CameraMediaPicker: NSObject, PhotoMediaPickerSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    public let title: String

    public var savePhotoMedia: ((UIImage) -> ())?

    public init(title: String = NSLocalizedString("Camera", comment: "")) {
        self.title = title
    }

    public func viewController() -> UIViewController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        return imagePickerController
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            savePhotoMedia?(image)
        }

        picker.dismiss(animated: true, completion: nil)
    }

}

/// Choose image from the photo library.
public class PhotoLibraryMediaPicker: NSObject, PhotoMediaPickerSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public let title: String

    public var savePhotoMedia: ((UIImage) -> ())?

    public init(title: String = NSLocalizedString("Photo Library", comment: "")) {
        self.title = title
    }

    public func viewController() -> UIViewController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.modalPresentationStyle = .popover
        imagePickerController.delegate = self
        return imagePickerController
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            savePhotoMedia?(image)
        }

        picker.dismiss(animated: true, completion: nil)
    }

}
