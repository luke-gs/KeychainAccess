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

    var lastPoint: CGPoint?
    var pathLength: CGFloat = 0.0
    var minimumDrawDistance: CGFloat = 25.0
    var maximumPathLength: CGFloat = 150.0

    var exceedsMaxPathLength: Bool {
        return pathLength > maximumPathLength
    }

    var isEmpty: Bool {
        return lastPoint == nil
    }

    var controlPoint: Int = 0

    private(set) var leading: CGPoint = .zero
    private(set) var leadingControl: CGPoint = .zero
    private(set) var middle: CGPoint = .zero
    private(set) var trailingControl: CGPoint = .zero
    private(set) var trailing: CGPoint = .zero

    func setPoint(_ location: PointLocation, to newValue: CGPoint) {
        switch location {
        case .leading: leading = newValue
        case .leadingControl: leadingControl = newValue
        case .middle: middle = newValue
        case .trailingControl: trailingControl = newValue
        case .trailing: trailing = newValue

        }
    }

    var isAtLastPoint: Bool {
        return controlPoint == PointLocation.trailing.rawValue
    }

    var isAtFirstPoint: Bool {
        return controlPoint == PointLocation.leadingControl.rawValue && pathLength == 0.0
    }

    var calculatedCenterPoint: CGPoint {
        return CGPoint(x: (middle.x + trailing.x) * 0.5, y: (middle.y + trailing.y) * 0.5)
    }

    func distance(to point: CGPoint) -> CGFloat {
        if let lastPoint = lastPoint {
            let dx = Double(point.x - lastPoint.x)
            let dy = Double(point.y - lastPoint.y)

            return CGFloat(sqrt(dx * dx + dy * dy))
        }
        return 0.0
    }

    func shouldDraw(to currentPoint: CGPoint) -> Bool {
        guard let previousPoint = lastPoint else {
            return true
        }
        let dx = currentPoint.x - previousPoint.x
        let dy = currentPoint.y - previousPoint.y
        return ((dx * dx) + (dy * dy)) > minimumDrawDistance
    }
}
