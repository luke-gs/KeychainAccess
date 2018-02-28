//
//  AudioMedia.swift
//  MPOLKit
//
//  Created by QHMW64 on 23/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import AVKit

public class AudioMedia: MediaPreview {

    public init(asset: Media) {
        super.init(asset: asset)

        if let samples = AudioSampler.waveformSamples(fromAudioFile: asset.url, count: 44100) {
            thumbnailImage = UIImage.waveformImage(from: samples,
                                                  fittingSize: CGSize(width: 600, height: 450))
        }

        title = asset.title
        comments = asset.comments
        sensitive = asset.sensitive
    }
    
}
