//
//  PathBuilder.swift
//  Sketchy
//
//  Created by QHMW64 on 11/1/18.
//  Copyright © 2018 Sketchy. All rights reserved.
//

import UIKit

public enum PointLocation: Int {
    case leading = 0
    case leadingControl = 1
    case middle = 2
    case trailingControl = 3
    case trailing = 4

    public init(_ controlPoint: Int) {
        self = PointLocation(rawValue: controlPoint) ?? .leading
    }
}

/// How to understand the line breakup
/// ******************************************************************************
///
///    |----------------*-----------------*--------------*------------------|
///    Leading    LeadingControl       Middle     TrailingControl    Trailing
///
///
///                 ..O..
///              ...      ...
///            ..             ..
///          ..                 .
///       ..                      .
///     .                          ..
///    ..                            ..                                O
///    O                               O                              ..
///                                     ..                           ..
///                                      ..                       ..
///                                        ..                   ..
///                                          ..              ..
///                                            ...        ...
///                                               ...O...
///
/// ******************************************************************************
public class PathBuilder {

    public var lastPoint: CGPoint?
    public var pathLength: CGFloat = 0.0
    public var minimumDrawDistance: CGFloat = 25.0
    public var maximumPathLength: CGFloat = 150.0

    public var exceedsMaxPathLength: Bool {
        return pathLength > maximumPathLength
    }

    public var isEmpty: Bool {
        return lastPoint == nil
    }

    public var controlPoint: Int = 0

    public init() {
    }

    public private(set) var leading: CGPoint = .zero
    public private(set) var leadingControl: CGPoint = .zero
    public private(set) var middle: CGPoint = .zero
    public private(set) var trailingControl: CGPoint = .zero
    public private(set) var trailing: CGPoint = .zero

    public func setPoint(_ location: PointLocation, to newValue: CGPoint) {
        switch location {
        case .leading: leading = newValue
        case .leadingControl: leadingControl = newValue
        case .middle: middle = newValue
        case .trailingControl: trailingControl = newValue
        case .trailing: trailing = newValue

        }
    }

    public var isAtLastPoint: Bool {
        return controlPoint == PointLocation.trailing.rawValue
    }

    public var isAtFirstPoint: Bool {
        return controlPoint == PointLocation.leadingControl.rawValue && pathLength == 0.0
    }

    public var calculatedCenterPoint: CGPoint {
        return CGPoint(x: (middle.x + trailing.x) * 0.5, y: (middle.y + trailing.y) * 0.5)
    }

    public func distance(to point: CGPoint) -> CGFloat {
        if let lastPoint = lastPoint {
            let dx = Double(point.x - lastPoint.x)
            let dy = Double(point.y - lastPoint.y)

            return CGFloat(sqrt(dx * dx + dy * dy))
        }
        return 0.0
    }

    public func shouldDraw(to currentPoint: CGPoint) -> Bool {
        guard let previousPoint = lastPoint else {
            return true
        }
        let dx = currentPoint.x - previousPoint.x
        let dy = currentPoint.y - previousPoint.y
        return ((dx * dx) + (dy * dy)) > minimumDrawDistance
    }
}
