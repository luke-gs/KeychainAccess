//
//  AudioSampler.swift
//  MPOLKit
//
//  Created by QHMW64 on 2/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import Accelerate
import AVKit

final class AudioSampler {

    private static let minimumDecibels: Float = -50.0

    static func waveformSamples(fromAudioFile url: URL, count: Int) -> [Float]? {

        var assetReader: AVAssetReader
        do {
            assetReader = try AVAssetReader(asset: AVAsset(url: url))
        } catch {
            // Failed to instantiate an assetReader
            print(error)
            return nil
        }
        
        guard let audioTrack = assetReader.asset.tracks.first else { return nil }

        // A basic set of settings used to read the file
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]

        let trackOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: settings)
        assetReader.add(trackOutput)
        let samples = extract(samplesFrom: assetReader, downsampledTo: count)

        switch assetReader.status {
        case .completed:
            // Normalise the values against the mininum decibel level
            return samples.map { $0 / -50.0 }
        default:
            // Asset Reader has failed to read the audio file samples
            return nil
        }
    }

    fileprivate static func extract(samplesFrom assetReader: AVAssetReader,
                                    downsampledTo targetSampleCount: Int) -> [Float] {
        var outputSamples = [Float]()

        assetReader.startReading()
        while assetReader.status == .reading {
            let trackOutput = assetReader.outputs.first!

            if let sampleBuffer = trackOutput.copyNextSampleBuffer(),
                let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) {
                let blockBufferLength = CMBlockBufferGetDataLength(blockBuffer)
                let sampleLength = CMSampleBufferGetNumSamples(sampleBuffer) * channelCount(from: assetReader)
                var data = Data(capacity: blockBufferLength)
                data.withUnsafeMutableBytes { (blockSamples: UnsafeMutablePointer<Int16>) in
                    CMBlockBufferCopyDataBytes(blockBuffer, 0, blockBufferLength, blockSamples)
                    CMSampleBufferInvalidate(sampleBuffer)

                    let processedSamples = process(blockSamples,
                                                   ofLength: sampleLength,
                                                   from: assetReader,
                                                   downsampledTo: targetSampleCount)
                    outputSamples += processedSamples
                }
            }
        }
        var paddedSamples = [Float](repeating: -50.0, count: targetSampleCount)
        paddedSamples.replaceSubrange(0..<min(targetSampleCount,
                                              outputSamples.count),
                                      with: outputSamples)

        return paddedSamples
    }

    private static func process(_ samples: UnsafeMutablePointer<Int16>,
                         ofLength sampleLength: Int,
                         from assetReader: AVAssetReader,
                         downsampledTo targetSampleCount: Int) -> [Float] {
        var loudestClipValue: Float = 0.0
        var quietestClipValue: Float = -50.0
        var zeroDbEquivalent: Float = Float(Int16.max)
        let samplesToProcess = vDSP_Length(sampleLength)

        var processingBuffer = [Float](repeating: 0.0, count: Int(samplesToProcess))
        vDSP_vflt16(samples, 1, &processingBuffer, 1, samplesToProcess)
        vDSP_vabs(processingBuffer, 1, &processingBuffer, 1, samplesToProcess)
        vDSP_vdbcon(processingBuffer, 1, &zeroDbEquivalent, &processingBuffer, 1, samplesToProcess, 1)
        vDSP_vclip(processingBuffer, 1, &quietestClipValue, &loudestClipValue, &processingBuffer, 1, samplesToProcess)

        let samplesPerPixel = max(1, sampleCount(from: assetReader) / targetSampleCount)
        let filter = [Float](repeating: 1.0 / Float(samplesPerPixel), count: samplesPerPixel)
        let downSampledLength = sampleLength / samplesPerPixel
        var downSampledData = [Float](repeating: 0.0, count: downSampledLength)

        vDSP_desamp(processingBuffer,
                    vDSP_Stride(samplesPerPixel),
                    filter,
                    &downSampledData,
                    vDSP_Length(downSampledLength),
                    vDSP_Length(samplesPerPixel))

        return downSampledData
    }

    private static func sampleCount(from assetReader: AVAssetReader) -> Int {
        let samplesPerChannel = Int(assetReader.asset.duration.value)
        return samplesPerChannel * channelCount(from: assetReader)
    }

    private static func channelCount(from assetReader: AVAssetReader) -> Int {
        let audioTrack = (assetReader.outputs.first as? AVAssetReaderTrackOutput)?.track

        var channelCount = 0
        audioTrack?.formatDescriptions.forEach { formatDescription in
            let audioDescription = CFBridgingRetain(formatDescription) as! CMAudioFormatDescription
            if let basicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(audioDescription) {
                channelCount = Int(basicDescription.pointee.mChannelsPerFrame)
            }
        }
        return channelCount
    }
}

extension UIImage {


    /// A rendered image of an audio waveform
    ///
    /// - Parameters:
    ///   - samples: The normalised samples that will be used to draw each point
    ///   - size: The size in which to draw the waveform
    /// - Returns: An image representation of a waveform
    static func waveformImage(from samples: [Float], fittingSize size: CGSize) -> UIImage? {

        let scale = UIScreen.main.scale

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()!

        // Context settings
        context.setAllowsAntialiasing(true)
        context.setShouldAntialias(true)
        context.setLineWidth(1.0 / UIScreen.main.scale)
        context.setStrokeColor(UIColor(red:0.26, green:0.65, blue:0.86, alpha:1.00).cgColor)
        context.setFillColor(UIColor(red:0.16, green:0.16, blue:0.17, alpha:1.00).cgColor)

        let graphRect = CGRect(origin: CGPoint.zero, size: size)
        let positionAdjustedGraphCenter = CGFloat(0.5 * graphRect.size.height)
        let drawMappingFactor = graphRect.size.height / 2.5
        var maxAmplitude: CGFloat = 0.0

        // If there is no sound, draw a 1px line
        let minimumGraphAmplitude: CGFloat = 1
        let path = CGMutablePath()

        for (x, sample) in samples.enumerated() {
            let xPos = CGFloat(x) / scale
            let invertedDbSample = 1 - CGFloat(sample) // sample is in dB, linearly normalized to [0, 1] (1 -> -50 dB)
            let drawingAmplitude = max(minimumGraphAmplitude, invertedDbSample * drawMappingFactor)
            let drawingAmplitudeUp = positionAdjustedGraphCenter - drawingAmplitude
            let drawingAmplitudeDown = positionAdjustedGraphCenter + drawingAmplitude
            maxAmplitude = max(drawingAmplitude, maxAmplitude)

            if Int(xPos) % 5 != 0 { continue }

            path.move(to: CGPoint(x: xPos, y: drawingAmplitudeUp))
            path.addLine(to: CGPoint(x: xPos, y: drawingAmplitudeDown))
        }

        // Fill the background color and then add/stroke the path
        context.fill(CGRect(origin: .zero, size: size))
        context.addPath(path)
        context.strokePath()

        let waveform = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return waveform
    }
}
