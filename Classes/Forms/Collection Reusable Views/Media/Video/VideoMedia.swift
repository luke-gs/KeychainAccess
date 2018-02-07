//
//  VideoMedia.swift
//  MPOLKit
//
//  Created by QHMW64 on 23/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import AVKit

public class VideoMedia: MediaPreview {

    public init(asset: Media) {
        super.init(asset: asset)

        let videoAsset = AVAsset(url: asset.url)
        let thumbnailGenerator = AVAssetImageGenerator(asset: videoAsset)
        thumbnailGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 100)
        do {
            let image = try thumbnailGenerator.copyCGImage(at: time, actualTime: nil)
            thumbnailImage = UIImage(cgImage: image)
        } catch {
            print(error)
            // Unable to generate a thumbnail
            // Media gallery will use predefined image instead
        }
    }
}
