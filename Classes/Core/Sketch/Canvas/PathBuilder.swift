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
/// ******************************************************************************
public class PathBuilder {

    var lastPoint: CGPoint?
    var pathLength: CGFloat = 0.0
    var minimumDrawDistance: CGFloat = 25.0
    var maximumPathLength: CGFloat = 80.0

    var exceedsMaxPathLength: Bool {
        return pathLength > maximumPathLength
    }

    var isEmpty: Bool {
        return lastPoint == nil
    }

    var controlPoint: Int = 0
    private var points: [CGPoint] = [CGPoint(), CGPoint(), CGPoint(), CGPoint(), CGPoint()]

    var leading: CGPoint {
        return points[0]
    }
    var leadingControl: CGPoint {
        return points[1]
    }
    var middle: CGPoint {
        return points[2]
    }
    var trailingControl: CGPoint {
        return points[3]
    }
    var trailing: CGPoint {
        return points[4]
    }

    func setPoint(_ location: PointLocation, to newValue: CGPoint) {
        points[location.rawValue] = newValue
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
