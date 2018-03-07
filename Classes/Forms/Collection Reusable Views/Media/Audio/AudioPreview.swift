//
//  AudioPreview.swift
//  MPOLKit
//
//  Created by QHMW64 on 23/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import AVKit

public class AudioPreview: MediaPreview {

    public init(media: Media) {
        var thumbnailImage: UIImage?

        if let samples = AudioSampler.waveformSamples(fromAudioFile: media.url, count: 44100) {
            thumbnailImage = UIImage.waveformImage(from: samples,
                                                  fittingSize: CGSize(width: 600, height: 450))
        }

        super.init(thumbnailImage: thumbnailImage, media: media)
    }
    
}
