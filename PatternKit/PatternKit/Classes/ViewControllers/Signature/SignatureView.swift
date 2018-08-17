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
            signatureLayer.lineWidth = strokeWidth
        }
    }

    open var strokeColor: UIColor = .darkGray {
        didSet {
            strokeColor.setStroke()
            signatureLayer.strokeColor = strokeColor.cgColor
        }
    }

    /// Can be used to determine whether the signature has been started
    /// Checks that the path is not empty for validation
    public var containsSignature: Bool {
        return !path.isEmpty
    }

    /// Animation layer for the clearing of the signature
    fileprivate lazy var signatureLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = frame
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.lineWidth = strokeWidth
        layer.addSublayer(shapeLayer)
        return shapeLayer
    }()

    fileprivate var path = UIBezierPath()
    // Control points for line smoothing
    fileprivate var pathBuilder: PathBuilder = PathBuilder()
    
    override public func draw(_ rect: CGRect) {
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
        MPLCodingNotSupported()
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            pathBuilder.controlPoint = 0
            pathBuilder.setPoint(.leading, to: touch.location(in: self))
        }
        delegate?.didStartSigning()
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            pathBuilder.controlPoint += 1
            pathBuilder.setPoint(PointLocation(pathBuilder.controlPoint), to: point)
            if pathBuilder.isAtLastPoint {

                // Calculate the center of the points, set the middle point to the calculated value and add a curve to it
                let centerPoint = pathBuilder.calculatedCenterPoint
                pathBuilder.setPoint(.trailingControl, to: centerPoint)
                path.move(to: pathBuilder.leading)
                path.addCurve(to: pathBuilder.trailingControl, controlPoint1: pathBuilder.leadingControl, controlPoint2: pathBuilder.middle)

                pathBuilder.setPoint(.leading, to: pathBuilder.trailingControl)
                pathBuilder.setPoint(.leadingControl, to: pathBuilder.trailing)
                pathBuilder.controlPoint = 1
            }

            setNeedsDisplay()
        }
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if pathBuilder.controlPoint < 4 {
            let touchPoint = pathBuilder.leading
            path.move(to: touchPoint)
            path.addLine(to: touchPoint)
            setNeedsDisplay()
        } else {
            pathBuilder.controlPoint = 0
        }
        delegate?.didEndSigning()
    }

    public func clear() {
        guard containsSignature else {
            return
        }

        let pathCopy = path.copy() as! UIBezierPath

        path.removeAllPoints()
        setNeedsDisplay()

        signatureLayer.path = pathCopy.cgPath

        // Animate the reverse drawing of the signature
        // Puts a copy of the actual signature on top, removes the old one and
        // animates backwards, removing on completion
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.toValue = 0.0
        animation.duration = 0.3
        animation.fillMode = kCAFillModeBoth
        animation.isRemovedOnCompletion = false

        signatureLayer.add(animation, forKey: "reverseSignature")
    }


    /// The result image to be supplied
    ///
    /// - Parameters:
    ///   - isOpaque: Whether or not to display the signature on a background
    ///   - backgroundColor: The colour of the background colour if they want one
    /// - Returns: An image representation of the signature
    public func renderedImage(isOpaque: Bool = false, backgroundColor: UIColor? = nil) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, isOpaque, 0)

        // Set the background colur if supplied
        backgroundColor?.setFill()

        strokeColor.setStroke()
        path.lineWidth = strokeWidth
        path.stroke()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
