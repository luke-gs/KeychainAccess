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

/// Draw an image using sketch
public class SketchMediaPicker: NSObject, PhotoMediaPickerSource, SketchPickerControllerDelegate {

    public let title: String

    public var savePhotoMedia: ((UIImage) -> ())?

    public init(title: String = NSLocalizedString("Sketch", comment: "")) {
        self.title = title
    }

    public func viewController() -> UIViewController {
        let sketchPickerController = SketchPickerController()
        sketchPickerController.delegate = self
        let navigationController = SketchNavigationController(rootViewController: sketchPickerController)
        return navigationController
    }
    
    func sketchPickerController(_ picker: SketchPickerController, didFinishPickingSketch sketch: UIImage) {
        savePhotoMedia?(sketch)
        picker.dismiss(animated: true, completion: nil)
    }

    func sketchPickerControllerDidCancel(_ picker: SketchPickerController) {
        // Perform something here when canceled

        picker.dismiss(animated: true, completion: nil)
    }

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
