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

    private var generator: UIFeedbackGenerator?

    /// Initialises and prepares a new generator based on the passed HapticType
    public func prepare(type: HapticType) {
        let generator: UIFeedbackGenerator
        switch (type) {
        case .error: generator = StoredNotificationGenerator(type: .error)
        case .success: generator = StoredNotificationGenerator(type: .success)
        case .warning: generator = StoredNotificationGenerator(type: .warning)

        case .light: generator = UIImpactFeedbackGenerator(style: .light)
        case .medium: generator = UIImpactFeedbackGenerator(style: .medium)
        case .heavy: generator = UIImpactFeedbackGenerator(style: .heavy)

        case .change: generator = UISelectionFeedbackGenerator()
        }

        generator.prepare()
        self.generator = generator
    }

    /// Triggers haptic feedback according to the currently prepared feedback generator. If no feedback has been prepared, no feedback will trigger.
    public func trigger() {
        if let generator = generator as? StoredNotificationGenerator {
            generator.notificationOccurred(.success)
            return

        } else if let generator = generator as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
            return

        } else if let generator = generator as? UISelectionFeedbackGenerator {
            generator.selectionChanged()
            return

        }
    }

    /// Prepares a new haptic type and fires immediately. Shouldn't technically be used, but the difference isn't particularly noticeable for single-use haptics.
    public func prepareAndTrigger(type: HapticType) {
        prepare(type: type)
        trigger()
    }

}

fileprivate class StoredNotificationGenerator: UINotificationFeedbackGenerator {
    private let feedbackType: UINotificationFeedbackType

    public required init(type: UINotificationFeedbackType) {
        self.feedbackType = type
        super.init()
    }

    public func trigger() {
        self.notificationOccurred(self.feedbackType)
    }
}
