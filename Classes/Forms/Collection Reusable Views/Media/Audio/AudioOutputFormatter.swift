//
//  AudioOutputFormatter.swift
//  MPOLKit
//
//  Created by QHMW64 on 1/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

class AudioOutputFormatter {

    // Decibels come from audio providers as a Float
    static func normalisedOutputValue(from decibels: Float?) -> CGFloat {
        guard let decibels = decibels else { return 0.0 }

        return powerLevel(from: CGFloat(decibels))
    }

    private static func powerLevel(from decibels: CGFloat) -> CGFloat {
        guard decibels > -60 && decibels != 0.0 else { return 0.0 }

        // Convert decibels into a power level
        let minDecibels: CGFloat = -60.0
        let root: CGFloat = 2.0
        let minAmp: CGFloat = pow(10.0, 0.05 * minDecibels)
        let inverseAmpRange = 1.0 / (1.0 - minAmp)
        let amp: CGFloat = pow(10.0, 0.05 * decibels)
        let adjAmp: CGFloat = (amp - minAmp) * inverseAmpRange

        return pow(adjAmp, 1.0 / root)
    }
}
