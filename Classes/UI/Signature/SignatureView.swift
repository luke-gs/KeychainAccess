//
//  SignatureView.swift
//  MPOLKit
//
//  Created by QHMW64 on 21/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public protocol SignatureViewResponder: class {
    func didStartSigning()
    func didEndSigning()
}

public class SignatureView: UIView {

    weak public var delegate: SignatureViewResponder?

    open var strokeWidth: CGFloat = 4.0 {
        didSet {
            path.lineWidth = strokeWidth
        }
    }

    open var strokeColor: UIColor = .darkGray {
        didSet {
            strokeColor.setStroke()
        }
    }

    fileprivate var path = UIBezierPath()
    fileprivate var points: LineControlPoints = LineControlPoints()

    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        strokeColor.setStroke()
        path.stroke()
    }

    public init() {
        super.init(frame: .zero)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = UIColor(red:0.92, green:0.92, blue:0.93, alpha:1.00)
        path.lineWidth = strokeWidth
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            points.controlPoint = 0
            points.setPoint(.left, to: touch.location(in: self))
        }
        delegate?.didStartSigning()
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            var controlPoint = points.controlPoint
            // Increment the control point
            controlPoint += 1
            points.setPoint(PointLocation(controlPoint), to: point)

            if points.isAtLastPoint() {

                // Calculate the center of the points, set the middle point to the calculated value and add a curve to it
                let centerPoint = CGPoint(x: (points.middle.x + points.trailing.x) * 0.5, y: (points.middle.y + points.trailing.y) * 0.5)
                points.setPoint(.rightMiddle, to: centerPoint)
                path.move(to: points.leading)
                path.addCurve(to: points.trailingControl, controlPoint1: points.middleControl, controlPoint2: points.middle)

                setNeedsDisplay()
                points.setPoint(.left, to: points.trailingControl)
                points.setPoint(.leftMiddle, to: points.trailing)
                points.controlPoint = 1
            }

            setNeedsDisplay()
        }
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if points.controlPoint < 4 {
            let touchPoint = points.leading
            path.move(to: touchPoint)
            path.addLine(to: touchPoint)
            setNeedsDisplay()
        } else {
            points.controlPoint = 0
        }
        delegate?.didEndSigning()
    }

    func clear() {
        UIView.animate(withDuration: 0.2) { [unowned self] in
            self.path.removeAllPoints()
            self.setNeedsDisplay()
        }
    }

    public var image: UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        UIColor.clear.setFill()
        strokeColor.setStroke()
        path.lineWidth = strokeWidth
        path.stroke()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

public enum PointLocation: Int {
    case left = 0
    case leftMiddle
    case middle
    case rightMiddle
    case right

    init(_ controlPoint: Int) {
        self = PointLocation(rawValue: controlPoint) ?? .left
    }
}


/// How to understand the line breakup
/// ******************************************************************************
///
///    |----------------*-----------------*--------------*------------------|
///    Leading    LeadingControl       Middle     TrailingControl    Trailing
///
/// ******************************************************************************
private class LineControlPoints {

    var controlPoint: Int = 0
    private var points: [CGPoint] = [CGPoint(), CGPoint(), CGPoint(), CGPoint(), CGPoint()]

    var leading: CGPoint {
        return points[0]
    }
    var middleControl: CGPoint {
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

    func isAtLastPoint() -> Bool {
        return controlPoint == PointLocation.right.rawValue
    }
}
