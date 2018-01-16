//
//  AnimationStyle.swift
//  MPOLKit
//
//  Created by QHMW64 on 4/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public enum AnimationStyle: Equatable {

    public static func ==(lhs: AnimationStyle, rhs: AnimationStyle) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.animated(let a), .animated(let b)):
            return a.isEqual(b)
        case (.fade, .fade):
            return true
        case (.enlarge, .enlarge):
            return true
        case (.underline, .underline):
            return true
        default:
            return false
        }
    }

    case none
    // Provide a custom style that the cells should be animated by
    case animated(style: CellSelectionAnimatable)

    // Framework Defaults
    case fade
    case enlarge
    case underline


    /// Called to configure the cell when it is either highlighted or selected
    /// The app can provide its own custom animations with .animated, or use
    /// the ones provided such as .fade or .underline
    /// - Parameter cell: The cell that is to be configured.
    func configure(_ cell: CollectionViewFormCell) {
        switch self {
        case .none:
            break
        case .animated(let style):
            type(of: style).configure(cell)
        case .enlarge:
            EnlargeStyle.configure(cell)
        case .fade:
            FadeStyle.configure(cell)
        case .underline:
            UnderlineStyle.configure(cell)
        }
    }
}

public protocol CellSelectionAnimatable {
    static func configure(_ cell: CollectionViewFormCell)
    func isEqual(_ rhs: CellSelectionAnimatable) -> Bool
}

extension CellSelectionAnimatable {
    public func isEqual(_ rhs: CellSelectionAnimatable) -> Bool {
        return type(of: self) == type(of: rhs)
    }
}
