//
//  HapticHelper.swift
//  MPOLKit
//
//  Created by Bryan Hathaway on 7/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import UIKit

public enum HapticType {
    case error
    case success
    case warning

    case light
    case medium
    case heavy

    case change
}

public class HapticHelper {

    public static let shared = HapticHelper()

    private var generators: [HapticType : UIFeedbackGenerator] = [:]

    private init() { }

    /// Initialises and prepares a new generator based on the passed HapticType
    /// You should call this just before the haptic is expected to fire, otherwise iOS will return the generator to idle state after a few seconds.
    public func prepare(_ type: HapticType) {

        // If already initialised, just prepare it again.
        if let generator = generators[type] {
            generator.prepare()
            return
        }

        // Initialise a new generator
        let generator: UIFeedbackGenerator
        switch (type) {
        case .error: generator = UINotificationFeedbackGenerator()
        case .success: generator = UINotificationFeedbackGenerator()
        case .warning: generator = UINotificationFeedbackGenerator()

        case .light: generator = UIImpactFeedbackGenerator(style: .light)
        case .medium: generator = UIImpactFeedbackGenerator(style: .medium)
        case .heavy: generator = UIImpactFeedbackGenerator(style: .heavy)

        case .change: generator = UISelectionFeedbackGenerator()
        }

        generator.prepare()
        generators[type] = generator
    }

    /// Triggers haptic feedback according to the currently prepared feedback generator. If no feedback has been prepared, no feedback will trigger.
    public func trigger(_ type: HapticType) {

        // If not in the dictionary, call prepare first.
        guard let generator = generators[type] else {
            prepare(type)
            trigger(type)
            return
        }

        if let generator = generator as? UINotificationFeedbackGenerator {
            generator.trigger(type)
            return

        } else if let generator = generator as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
            return

        } else if let generator = generator as? UISelectionFeedbackGenerator {
            generator.selectionChanged()
            return

        }
    }
}

// Convenience to map our enum to this generator's enum.
fileprivate extension UINotificationFeedbackGenerator {
    fileprivate func trigger(_ type: HapticType) {
        let realType: UINotificationFeedbackType
        switch type {
        case .warning: realType = .warning
        case .success: realType = .success
        case .error: realType = .error
        default: return
        }

        self.notificationOccurred(realType)
    }
}
