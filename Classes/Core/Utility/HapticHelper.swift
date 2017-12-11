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

    /// Returns the generator for the given HapticType, initializing it if necessary.
    private func generatorForType(_ type: HapticType) -> UIFeedbackGenerator {
        // If exists, return it
        if let generator = generators[type] {
            return generator
        }

        // Otherwise, intialize new generator
        let generator: UIFeedbackGenerator
        switch (type) {
        case .error: fallthrough
        case .success: fallthrough
        case .warning: generator = UINotificationFeedbackGenerator()

        case .light: generator = UIImpactFeedbackGenerator(style: .light)
        case .medium: generator = UIImpactFeedbackGenerator(style: .medium)
        case .heavy: generator = UIImpactFeedbackGenerator(style: .heavy)

        case .change: generator = UISelectionFeedbackGenerator()
        }
        generators[type] = generator

        return generator
    }

    /// Prepares a generator based on the given HapticType.
    /// You should call this just before the haptic is expected to fire, otherwise iOS will return the generator to idle state after a few seconds.
    public func prepare(_ type: HapticType) {
        let generator = generatorForType(type)

        generator.prepare()
    }

    /// Triggers haptic feedback according to the given HapticType.
    /// You should ideally call prepare() before using this.
    public func trigger(_ type: HapticType) {
        let generator = generatorForType(type)

        if let generator = generator as? UINotificationFeedbackGenerator {
            generator.trigger(type)

        } else if let generator = generator as? UIImpactFeedbackGenerator {
            generator.impactOccurred()

        } else if let generator = generator as? UISelectionFeedbackGenerator {
            generator.selectionChanged()

        }

        // Generators typically only fire once. Remove when used.
        generators[type] = nil
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
