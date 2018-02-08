//
//  PersistantMediaDatasource.swift
//  MPOLKit
//
//  Created by QHMW64 on 8/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public class PersistantMediaDatasource: MediaDataSource {

    let mediaManager: MediaFileManager

    func saveFile(to url: URL, fromURL: URL) throws {
        try mediaManager.save(fromURL: fromURL, to: url)
    }

    required public init(items: [MediaPreviewable]) throws {
        mediaManager = try MediaFileManager()

        super.init(mediaItems: items)
    }
}

public class MediaFileManager {

    public let basePath: URL
    private let manager: FileManager = FileManager.default

    public private(set) var paths: FilePathExtensions

    //References to audio, video and photo urlsvar audioURL: URL

    public static let defaultBasePath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    init(basePath: URL = MediaFileManager.defaultBasePath, filePaths: FilePathExtensions = FilePathExtensions()) throws {

        self.basePath = basePath

        let audioPath = basePath.appendingPathComponent("audio", isDirectory: true)
        let videoPath = basePath.appendingPathComponent("video", isDirectory: true)
        let photoPath = basePath.appendingPathComponent("photos", isDirectory: true)

        paths = filePaths

        // Construct the directory paths
        try manager.createDirectory(at: audioPath, withIntermediateDirectories: true, attributes: nil)
        try manager.createDirectory(at: videoPath, withIntermediateDirectories: true, attributes: nil)
        try manager.createDirectory(at: photoPath, withIntermediateDirectories: true, attributes: nil)
    }

    public func save(fromURL url: URL, to location: URL) throws {
        // Copies the item at the url provided to the new location
        try manager.copyItem(at: url, to: location)
    }

    public func url(forPath path: String) -> URL? {
        return basePath.appendingPathComponent(path)
    }

}

public struct FilePathExtensions {
    var audio: String
    var video: String
    var photo: String

    init(audio: String = "audio", video: String = "video", photo: String = "photo") {
        self.audio = audio
        self.video = video
        self.photo = photo
    }
}
