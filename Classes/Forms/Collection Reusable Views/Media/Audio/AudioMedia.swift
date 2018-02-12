//
//  AudioMedia.swift
//  MPOLKit
//
//  Created by QHMW64 on 23/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import AVKit

public class AudioMedia: MediaAsset {
    public init(thumbnailImage: ImageLoadable? = AssetManager.shared.image(forKey: .audioWave),
                audioURL: URL,
                title: String? = nil,
                comments: String? = nil,
                sensitive: Bool = false) {

        var waveFormImage: UIImage? = nil
        if let samples = AudioSampler.waveformSamples(fromAudioFile: audioURL, count: 44100) {
            waveFormImage = UIImage.waveformImage(from: samples,
                                                  fittingSize: CGSize(width: 600, height: 450))
        }

        super.init(thumbnailImage: waveFormImage ?? thumbnailImage,
                   assetURL: audioURL,
                   title: title,
                   comments: comments,
                   isSensitive: sensitive)
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
