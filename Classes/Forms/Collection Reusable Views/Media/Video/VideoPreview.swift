//
//  VideoPreview.swift
//  MPOLKit
//
//  Created by QHMW64 on 23/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import AVKit

public class VideoPreview: MediaPreview {

    public init(media: MediaAsset) {
        super.init(media: media)

        let videoAsset = AVAsset(url: media.url)
        let thumbnailGenerator = AVAssetImageGenerator(asset: videoAsset)
        thumbnailGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 100)
        do {
            let image = try thumbnailGenerator.copyCGImage(at: time, actualTime: nil)
            thumbnailImage = UIImage(cgImage: image)
        } catch {
            print(error)
        }
    }
}
