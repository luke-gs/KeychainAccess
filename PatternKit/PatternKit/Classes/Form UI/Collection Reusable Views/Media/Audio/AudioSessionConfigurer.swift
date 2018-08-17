//
//  AudioSessionConfigurer.swift
//  MPOLKit
//
//  Created by QHMW64 on 2/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import AVKit

public typealias AVRecorderSettings = [String: Any]

public class AudioSessionConfigurer {

    let session = AVAudioSession.sharedInstance()
    let configuration: AVConfigurations

    init(configuration: AVConfigurations = AVConfigurations()) {
        self.configuration = configuration
    }

    func presentRequestPermission(in viewController: UIViewController) {
        session.requestRecordPermission({ allowed in
            if !allowed {
                let alertController = UIAlertController(title: "Permissions Denied", message: "The app needs microphone settings to be allowed to record.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    viewController.dismiss(animated: true, completion: nil)
                })
                alertController.addAction(okAction)
                viewController.present(alertController, animated: true, completion: nil)
            }
        })
    }

    func configureActiveSession() {
        try? session.setCategory(configuration.category.value)
        try? session.setActive(true)
    }

    func player(forURL url: URL, withFileHint hint: String? = nil) -> AVAudioPlayer? {
        do {
            let player = try AVAudioPlayer(contentsOf: url, fileTypeHint: hint)
            player.isMeteringEnabled = true
            return player
        } catch {
            // Failed to initialise an audioPlayer from specified URL
            return nil
        }
    }

    func configuredRecorder(forURL url: URL, withSettings settings: AVRecorderSettings) -> AVAudioRecorder? {
        do {
            let recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder.isMeteringEnabled = configuration.isMeteringEnabled
            return recorder
        } catch {
            // Failed to configure with provided settings
            return nil
        }
    }

    static func defaultSettings(fromConfigs configs: AVConfigurations) -> AVRecorderSettings {
        let settings: AVRecorderSettings = [
            AVSampleRateKey: NSNumber(floatLiteral: configs.sampleRate),
            AVFormatIDKey: NSNumber(value: configs.format),
            AVNumberOfChannelsKey: NSNumber(value: configs.numberOfChannels),
            AVEncoderAudioQualityKey: NSNumber(value: configs.quality.rawValue)
        ]

        return settings
    }

}

public struct AVConfigurations {

    var category: AVSessionCategory
    var sampleRate: Double
    var format: AudioFormatID
    var numberOfChannels: Int
    var quality: AVAudioQuality
    var isMeteringEnabled: Bool
    var maxRecordLength: TimeInterval

    init(category: AVSessionCategory = .playAndRecord,
         sampleRate: Double = 44100,
         format: AudioFormatID = kAudioFormatMPEG4AAC,
         numberOfChannels: Int = 2,
         quality: AVAudioQuality = .medium,
         isMeteringEnabled: Bool = false,
         maxRecordLength: TimeInterval = Double.greatestFiniteMagnitude) {

        self.category = category
        self.sampleRate = sampleRate
        self.format = format
        self.numberOfChannels = numberOfChannels
        self.quality = quality
        self.isMeteringEnabled = isMeteringEnabled
        self.maxRecordLength = maxRecordLength
    }

}

public enum AVSessionCategory {
    case ambient
    case soloAmbient
    case playBack
    case record
    case playAndRecord

    var value: String {
        switch self {
        case .ambient: return AVAudioSessionCategoryAmbient
        case .soloAmbient: return AVAudioSessionCategorySoloAmbient
        case .playBack: return AVAudioSessionCategoryPlayback
        case .record: return AVAudioSessionCategoryRecord
        case .playAndRecord: return AVAudioSessionCategoryPlayAndRecord
        }
    }
}
