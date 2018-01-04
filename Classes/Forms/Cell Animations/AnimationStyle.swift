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
        default:
            return false
        }
    }

    case none
    case animated(style: CellSelectionAnimatable)

    func configure(_ cell: CollectionViewFormCell) {
        switch self {
        case .none:
            break
        case .animated(let style):
            style.configure(cell)
        }
    }
}

public protocol CellSelectionAnimatable {
    func configure(_ cell: CollectionViewFormCell)
    func isEqual(_ rhs: CellSelectionAnimatable) -> Bool
}

extension CellSelectionAnimatable {
    public func isEqual(_ rhs: CellSelectionAnimatable) -> Bool {
        return type(of: self) == type(of: rhs)
    }
}
