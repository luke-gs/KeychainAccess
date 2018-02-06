//
//  VideoMedia.swift
//  MPOLKit
//
//  Created by QHMW64 on 23/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import AVKit

public class VideoMedia: MediaAsset {

    public init(thumbnailImage: ImageLoadable? = AssetManager.shared.image(forKey: .play),
                videoURL: URL,
                title: String? = nil,
                comments: String? = nil,
                sensitive: Bool = false) {

        var customThumbnail: ImageLoadable?

        let asset = AVAsset(url: videoURL)
        let thumbnailGenerator = AVAssetImageGenerator(asset: asset)
        thumbnailGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 100)
        do {
            let image = try thumbnailGenerator.copyCGImage(at: time, actualTime: nil)
            customThumbnail = UIImage(cgImage: image)
        } catch {
            print(error)
            // Unable to generate a thumbnail
            // Media gallery will use predefined image instead
        }
        super.init(thumbnailImage: customThumbnail ?? thumbnailImage,
                   assetURL: videoURL,
                   title: title,
                   comments: comments, 
                   isSensitive: sensitive)

        AssetCache.default.store(self, for: videoURL.lastPathComponent)
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
