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

    public func trigger(type: HapticType) {
        switch (type) {
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)

        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)

        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)


        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()

        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()


        case .change:
            UISelectionFeedbackGenerator().selectionChanged()
        }

    }

}
