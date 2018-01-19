//
//  SketchPen.swift
//  Sketchy
//
//  Created by QHMW64 on 11/1/18.
//  Copyright © 2018 Sketchy. All rights reserved.
//

import UIKit

public class SketchPen: TouchTool {

    public var toolColor: UIColor = .darkGray {
        didSet {
            UIGraphicsGetCurrentContext()?.setStrokeColor(toolColor.cgColor)
        }
    }
    public var toolWidth: CGFloat = 5.0 {
        didSet {
            UIGraphicsGetCurrentContext()?.setLineWidth(toolWidth)
        }
    }

    public var imageView: UIImageView?
    public var image: UIImage?
    weak private var canvas: UIImageView?
    public private(set) var context: CGContext?
    
    var isEmpty: Bool {
        return pathBuilder.isEmpty
    }
    var bufferedDrawing: Bool {
        return true
    }
    private var path: CGMutablePath = CGMutablePath() {
        didSet {
            pathBuilder.pathLength = 0.0
        }
    }

    private var pathBuilder: PathBuilder = PathBuilder()

    public func touch(_ touch: UITouch, beganIn canvas: UIImageView) {
        self.canvas = canvas

        if bufferedDrawing {
            image = nil
            let imageView = UIImageView(frame: canvas.bounds)
            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            canvas.addSubview(imageView)
            self.imageView = imageView
        } else {
            imageView = canvas
            image = imageView?.image
        }

        pathBuilder.controlPoint = 0
        pathBuilder.setPoint(.leading, to: touch.location(in: canvas))
        moved(touch: touch)
    }

    public func moved(touch: UITouch) {
        let point = touch.location(in: canvas)

        guard pathBuilder.shouldDraw(to: point) == true else {
            return
        }
        imageView?.image = image
        drawCurve(to: touch)
        if pathBuilder.exceedsMaxPathLength {
            self.image = imageView?.image
            path = CGMutablePath()
        }
        pathBuilder.lastPoint = point
    }

    public func ended(touch: UITouch) {
        imageView?.image = image
        drawCurve(to: touch)

        path = CGMutablePath()
        image = nil

        if bufferedDrawing {
            bufferedImageView()
        }
    }

    internal func configureContext() {
        guard let imageView = imageView else {
            return
        }

        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, UIScreen.main.scale)
        imageView.image?.draw(in: imageView.bounds)

        context = UIGraphicsGetCurrentContext()
        context?.setLineCap(.round)
        context?.setLineWidth(toolWidth)
        context?.setLineJoin(.round)
        context?.setBlendMode(.normal)
        context?.setStrokeColor(toolColor.cgColor)
    }

    private func bufferedImageView() {
        if let canvas = canvas {
            UIGraphicsBeginImageContextWithOptions(canvas.bounds.size, false, UIScreen.main.scale)
            canvas.image?.draw(in: canvas.bounds)
            imageView?.image?.draw(in: canvas.frame, blendMode: .normal, alpha: 1.0)
            canvas.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            imageView?.removeFromSuperview()
            image = nil
        }
    }

    private func drawCurve(to touch: UITouch) {
        addPath(to: touch)

        if context == nil {
            configureContext()
            context = UIGraphicsGetCurrentContext()
        }

        context?.addPath(path)
        context?.strokePath()
        imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
    }

    private func addPath(to touch: UITouch) {
        let point = touch.location(in: imageView)
        pathBuilder.controlPoint += 1
        pathBuilder.setPoint(PointLocation(pathBuilder.controlPoint), to: point)

        if pathBuilder.isAtLastPoint {
            let subPath = CGMutablePath()
            // Calculate the center of the points, set the middle point to the calculated value and add a curve to it

            let centerPoint = pathBuilder.calculatedCenterPoint
            pathBuilder.setPoint(.trailingControl, to: centerPoint)
            subPath.move(to: pathBuilder.leading)
            subPath.addCurve(to: pathBuilder.trailingControl, control1: pathBuilder.leadingControl, control2: pathBuilder.middle)

            pathBuilder.setPoint(.leading, to: pathBuilder.trailingControl)
            pathBuilder.setPoint(.leadingControl, to: pathBuilder.trailing)
            pathBuilder.controlPoint = 1
            path.addPath(subPath)

            pathBuilder.pathLength += pathBuilder.distance(to: point)
        } else if pathBuilder.isAtFirstPoint {
            path.move(to: point)
            path.addLine(to: point)
        }
    }

    public func endDrawing() {
        UIGraphicsEndImageContext()
        if context != nil {
            context = nil
        }
    }
}
