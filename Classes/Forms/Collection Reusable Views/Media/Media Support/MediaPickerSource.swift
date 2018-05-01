//
//  MediaPickerSource.swift
//  MPOLKit
//
//  Created by KGWH78 on 16/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// A protocol that defines an input source for choosing an image
public protocol MediaPickerSource: class {

    /// The title that will be displayed as an option.
    var title: String { get }

    /// Call this closure to save the image.
    var saveMedia: ((Media) -> ())? { get set }

    /// The view controller to be presented.
    func viewController() -> UIViewController
}


public class AudioMediaPicker:  NSObject, MediaPickerSource, AudioRecorderControllerDelegate {

    private let temporaryLocation: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    public let title: String

    public init(title: String = NSLocalizedString("Audio", comment: "")) {
        self.title = title
    }

    public var saveMedia: ((Media) -> ())?

    public func viewController() -> UIViewController {
        let audioRecorderController = AudioRecordingViewController(saveLocation: temporaryLocation.appendingPathComponent("\(UUID().uuidString).m4a"))
        audioRecorderController.delegate = self
        let navigationController = UINavigationController(rootViewController: audioRecorderController)
        return navigationController
    }

    public func controller(_ controller: AudioRecordingViewController, didFinishWithRecordingURL url: URL) {
        saveMedia?(Media(url: url, type: .audio))
        controller.dismiss(animated: true, completion: nil)
    }

    public func controllerDidCancel(_ controller: AudioRecordingViewController) {
        // Handle cancellation here
    }
}

/// Draw an image using sketch
public class SketchMediaPicker: NSObject, MediaPickerSource, SketchPickerControllerDelegate {

    private let temporaryLocation: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!

    public let title: String

    public var saveMedia: ((Media) -> ())?

    public init(title: String = NSLocalizedString("Sketch", comment: "")) {
        self.title = title
    }

    public func viewController() -> UIViewController {
        let sketchPickerController = SketchPickerController()
        sketchPickerController.delegate = self
        let navigationController = SketchNavigationController(rootViewController: sketchPickerController)
        return navigationController
    }

    public func sketchPickerController(_ picker: SketchPickerController, didFinishPickingSketch sketch: UIImage) {
        if let imageRef = UIImageJPEGRepresentation(sketch, 0.5) {
            do {
                let location = temporaryLocation.appendingPathComponent("\(UUID().uuidString).jpg")
                try imageRef.write(to: location)
                saveMedia?(Media(url: location, type: .photo))
            } catch {
                print(error)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }

    public func sketchPickerControllerDidCancel(_ picker: SketchPickerController) {
        // Perform something here when canceled
        picker.dismiss(animated: true, completion: nil)
    }
}

/// Choose image from camera
public class CameraMediaPicker: NSObject, MediaPickerSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    private let temporaryLocation: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    public let title: String

    public var saveMedia: ((Media) -> ())?

    public init(title: String = NSLocalizedString("Camera", comment: "")) {
        self.title = title
    }

    public func viewController() -> UIViewController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) ?? imagePickerController.mediaTypes
        imagePickerController.delegate = self
        return imagePickerController
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Source is camera, so there's no `UIImagePickerControllerImageURL`
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage, let imageRef = UIImageJPEGRepresentation(image, 0.5) {
            do {
                let filePath = temporaryLocation.appendingPathComponent("\(UUID().uuidString).jpg")
                try imageRef.write(to: filePath)
                saveMedia?(Media(url: filePath, type: .photo))
            } catch {
                print(error)
            }

        } else if let url = info[UIImagePickerControllerMediaURL] as? URL {
            saveMedia?(Media(url: url, type: .video))
        }
        picker.dismiss(animated: true, completion: nil)
    }

}

/// Choose image from the photo library.
public class PhotoLibraryMediaPicker: NSObject, MediaPickerSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public let title: String
    private let temporaryLocation: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!

    public var saveMedia: ((Media) -> ())?

    public init(title: String = NSLocalizedString("Photo Library", comment: "")) {
        self.title = title
    }

    public func viewController() -> UIViewController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.modalPresentationStyle = .popover
        imagePickerController.delegate = self
        return imagePickerController
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if #available(iOS 11.0, *) {
            if let url = info[UIImagePickerControllerImageURL] as? URL {
                saveMedia?(Media(url: url, type: .photo))
            }
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage, let imageRef = UIImageJPEGRepresentation(image, 0.5) {
            do {
                let imageFilePath = temporaryLocation.appendingPathComponent("\(UUID().uuidString).jpg")
                try imageRef.write(to: imageFilePath)
                saveMedia?(Media(url: imageFilePath, type: .photo))
            } catch {
                print(error)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }

}
