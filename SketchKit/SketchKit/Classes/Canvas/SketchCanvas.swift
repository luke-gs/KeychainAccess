//
//  SketchyCanvas.swift
//  Sketchy
//
//  Created by QHMW64 on 10/1/18.
//  Copyright © 2018 Sketchy. All rights reserved.
//

import Foundation
import UIKit
import CoreKit

public enum SketchMode: Int {
    case draw
    case erase
}

public protocol SketchCanvasDelegate: class {

    /// Triggered when the canvas did start sketching in order to
    /// let the delegate know when drawing starts on the canvas
    /// Potentially called on every touch began
    func canvasDidStartSketching(_ canvas: Sketchable)

    /// Called whenever the user moves there touch over the canvas
    /// This allows the delegate to do any sort of operation, for
    /// example hiding the panel in certain positions
    func canvas(_ canvas: Sketchable, touchMovedTo position: CGPoint)

    /// Called whenever the sketch canvas did stop drawing touches
    /// Every time a new touch begins this will be called when the touch ends
    /// or is cancelled
    func canvasDidFinishSketching(_ canvas: Sketchable)
}

class SketchCanvas: UIView, Sketchable {

    private let eraser: SketchEraser
    private let pen: SketchPen
    public private(set) var currentTool: TouchTool
    weak var delegate: SketchCanvasDelegate?

    lazy var canvas: UIImageView = {
        let imageView = UIImageView(frame: bounds)
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        return imageView
    }()

    var currentContext: CGContext? {
        return currentTool.context
    }

    override var frame: CGRect {
        didSet {
            let oldHeight = oldValue.size.height
            let oldWidth = oldValue.size.width

            let xRatio = oldWidth / frame.width
            let yRatio = oldHeight / frame.height

            currentContext?.scaleBy(x: xRatio, y: yRatio)
        }
    }

    // The current mode of the canvas
    // When it changes, the current tool endsDrawing
    public var sketchMode: SketchMode = .draw {
        didSet {
            if oldValue == sketchMode { return }
            switch sketchMode {
            case .draw:
                eraser.endDrawing()
                currentTool = pen
            case .erase:
                pen.endDrawing()
                currentTool = eraser
            }
        }
    }

    init(pen: SketchPen = SketchPen(), eraser: SketchEraser = SketchEraser()) {

        self.eraser = eraser
        self.pen = pen

        currentTool = pen
        
        super.init(frame: .zero)

        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    // MARK: - Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            currentTool.touch(touch, beganIn: canvas)
        }
        delegate?.canvasDidStartSketching(self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let currentTouch = touches.first {
            currentTool.moved(touch: currentTouch)
            if let predictiveTouch = event?.predictedTouches(for: currentTouch)?.last {
                currentTool.moved(touch: predictiveTouch)
            }

            delegate?.canvas(self, touchMovedTo: currentTouch.location(in: canvas))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            currentTool.ended(touch: touch)
        }
        delegate?.canvasDidFinishSketching(self)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            currentTool.ended(touch: touch)
        }
        delegate?.canvasDidFinishSketching(self)
    }

    // MARK: - Sketchable

    func setToolColor(_ color: UIColor) {
        currentTool.toolColor = color
    }

    func setToolWidth(_ width: CGFloat) {
        currentTool.toolWidth = width
    }

    func renderedImage() -> UIImage? {
        return canvas.image
    }

    func clearCanvas() {
        pen.endDrawing()
        eraser.endDrawing()

        // Animate the clearing of the drawing
        UIView.animate(withDuration: 0.3, animations: {
            self.canvas.alpha = 0.0
        }, completion: { (success) in
            self.canvas.image = nil
            self.canvas.alpha = 1.0
        })

    }

    var isEmpty: Bool {
        return pen.isEmpty
    }
}
