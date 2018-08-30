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
        case (.tableView, .tableView):
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
    case tableView

    /// Called to configure the cell when it is either highlighted or selected
    /// The app can provide its own custom animations with .animated, or use
    /// the ones provided such as .fade or .underline
    /// - Parameters:
    ///   - cell: The cell to be animated
    ///   - state: This is passed in to deteremine whether to perform animations
    ///     eg when isSelected is called - forState: isSelected
    ///
    func configure(_ cell: CollectionViewFormCell, isFocused focused: Bool) {
        switch self {
        case .none:
            break
        case .animated(let style):
            type(of: style).configure(cell, isFocused: focused)
        case .enlarge:
            EnlargeStyle.configure(cell, isFocused: focused)
        case .fade:
            FadeStyle.configure(cell, isFocused: focused)
        case .underline:
            UnderlineStyle.configure(cell, isFocused: focused)
        case .tableView:
            TableViewStyle.configure(cell, isFocused: focused)
        }
    }
}

public protocol CellSelectionAnimatable {
    static func configure(_ cell: CollectionViewFormCell, isFocused focused: Bool)
    func isEqual(_ rhs: CellSelectionAnimatable) -> Bool
}

extension CellSelectionAnimatable {
    public func isEqual(_ rhs: CellSelectionAnimatable) -> Bool {
        return type(of: self) == type(of: rhs)
    }
}
