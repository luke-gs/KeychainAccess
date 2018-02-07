//
//  PersistantMediaDatasource.swift
//  MPOLKit
//
//  Created by QHMW64 on 8/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public class PersistantMediaDatasource: MediaDataSource {

    let mediaManager: MediaFileManager? = try? MediaFileManager()

    func saveFile(to url: URL, fromURL: URL) throws {
        try mediaManager?.cut(fromURL: fromURL, to: url)
    }

}

public class MediaFileManager {

    public let basePath: URL
    private let manager: FileManager = FileManager.default

    public static let defaultBasePath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    init(basePath: URL = MediaFileManager.defaultBasePath) throws {

        self.basePath = basePath

        let audioPath = basePath.appendingPathComponent("audio", isDirectory: true)
        let videoPath = basePath.appendingPathComponent("videos", isDirectory: true)
        let photoPath = basePath.appendingPathComponent("photos", isDirectory: true)

        // Construct the directory paths
        try manager.createDirectory(at: audioPath, withIntermediateDirectories: true, attributes: nil)
        try manager.createDirectory(at: videoPath, withIntermediateDirectories: true, attributes: nil)
        try manager.createDirectory(at: photoPath, withIntermediateDirectories: true, attributes: nil)
    }

    public func cut(fromURL url: URL, to location: URL) throws {
        // Copies the item at the url provided to the new location
        try manager.copyItem(at: url, to: location)

        // Remove the item at the temporary location
        try manager.removeItem(at: url)

    }

}
