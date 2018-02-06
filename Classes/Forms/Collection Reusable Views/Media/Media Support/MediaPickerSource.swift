//
//  MediaPickerSource.swift
//  MPOLKit
//
//  Created by KGWH78 on 16/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public enum MediaType {
    case video
    case audio
    case photo

    func mediaAsset(at url: URL) -> MediaAsset? {
        switch self {
        case .photo:
            if let data = try? Data(contentsOf: url) {
                let image = UIImage(data: data)
                return PhotoMedia(thumbnailImage: image, image: image, imageURL: url)
            }
            return nil
        case .audio:
            return AudioMedia(audioURL: url)
        case .video:
            return VideoMedia(videoURL: url)
        }
    }
}

/// A protocol that defines an input source for choosing an image
public protocol MediaPickerSource: class {

    /// The title that will be displayed as an option.
    var title: String { get }

    /// Call this closure to save the image.
    var saveMedia: ((URL, MediaType) -> ())? { get set }

    /// The view controller to be presented.
    func viewController() -> UIViewController

    /// The file path to which the media will be saved to
    var filePath: URL { get }
}


public class AudioMediaPicker:  NSObject, MediaPickerSource, AudioRecorderControllerDelegate {

    public let filePath: URL
    public let title: String

    public init(title: String = NSLocalizedString("Audio", comment: ""),
                filePath: URL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("\(UUID().uuidString).m4a")) {
        self.title = title
        self.filePath = filePath
    }

    public var saveMedia: ((URL, MediaType) -> ())?

    public func viewController() -> UIViewController {
        let audioRecorderController = AudioRecordingViewController(saveLocation: filePath)
        audioRecorderController.delegate = self
        let navigationController = UINavigationController(rootViewController: audioRecorderController)
        return navigationController
    }

    public func controller(_ controller: AudioRecordingViewController, didFinishWithRecordingURL url: URL) {
        saveMedia?(url, .audio)
        controller.dismiss(animated: true, completion: nil)
    }

    public func controllerDidCancel(_ controller: AudioRecordingViewController) {
        // Handle cancellation here
    }
}

/// Draw an image using sketch
public class SketchMediaPicker: NSObject, MediaPickerSource, SketchPickerControllerDelegate {

    public let filePath: URL
    public let title: String

    public var saveMedia: ((URL, MediaType) -> ())?

    public init(title: String = NSLocalizedString("Sketch", comment: ""),
                filePath: URL =  try! FileManager.default.url(for: .cachesDirectory,
                                                              in: .userDomainMask,
                                                              appropriateFor: nil,
                                                              create: true).appendingPathComponent("\(UUID().uuidString).jpg")) {
        self.title = title
        self.filePath = filePath
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
                try imageRef.write(to: filePath)
                saveMedia?(filePath, .photo)
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

    public let filePath: URL
    public let title: String

    public var saveMedia: ((URL, MediaType) -> ())?

    public init(title: String = NSLocalizedString("Camera", comment: ""),
                filePath: URL = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("\(UUID().uuidString).jpg")) {
        self.title = title
        self.filePath = filePath
    }

    public func viewController() -> UIViewController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) ?? imagePickerController.mediaTypes
        imagePickerController.delegate = self
        return imagePickerController
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var assetType: MediaType = .photo

        if #available(iOS 11.0, *) {
            if let url = info[UIImagePickerControllerImageURL] as? URL {
                saveMedia?(url, .photo)
            } else if let url = info[UIImagePickerControllerMediaURL] as? URL {
                saveMedia?(url, .video)
            }
        } else {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage, let imageRef = UIImageJPEGRepresentation(image, 0.5) {
                do {
                    try imageRef.write(to: filePath)
                    assetType = .photo
                    saveMedia?(filePath, assetType)
                } catch {
                    print(error)
                }

            } else if let url = info[UIImagePickerControllerMediaURL] as? URL {
                saveMedia?(url, .video)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }

}

/// Choose image from the photo library.
public class PhotoLibraryMediaPicker: NSObject, MediaPickerSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public let title: String
    public let filePath: URL

    public var saveMedia: ((URL, MediaType) -> ())?

    public init(title: String = NSLocalizedString("Photo Library", comment: ""),
                filePath: URL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)) {
        self.title = title
        self.filePath = filePath
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
                saveMedia?(url, .photo)
            }
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage, let imageRef = UIImageJPEGRepresentation(image, 0.5) {
            do {
                let imageFilePath = filePath.appendingPathComponent("\(UUID().uuidString).jpg")
                try imageRef.write(to: imageFilePath)
                saveMedia?(imageFilePath, .photo)
            } catch {
                print(error)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }

}
