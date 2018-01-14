//
//  SketchyCanvas.swift
//  Sketchy
//
//  Created by QHMW64 on 10/1/18.
//  Copyright © 2018 Sketchy. All rights reserved.
//

import Foundation
import UIKit

public enum SketchMode: Int {
    case draw
    case erase
}

public protocol Sketchable {
    var currentTool: TouchTool { get }
    var sketchMode: SketchMode { get set }
    func renderedImage() -> UIImage?

    func setToolColor(_ color: UIColor)
    func setToolWidth(_ width: CGFloat)
}

class SketchyCanvas: UIView, Sketchable {

    private let eraser: SketchyEraser
    private let pen: SketchyPen
    public private(set) var currentTool: TouchTool

    private lazy var canvas: UIImageView = {
        let imageView = UIImageView(frame: bounds)
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(imageView)
        return imageView
    }()

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

    init(pen: SketchyPen = SketchyPen(), eraser: SketchyEraser = SketchyEraser()) {

        self.eraser = eraser
        self.pen = pen

        currentTool = pen
        
        super.init(frame: .zero)

        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            currentTool.touch(touch, beganIn: canvas)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let currentTouch = touches.first {
            currentTool.moved(touch: currentTouch)
            if let predictiveTouch = event?.predictedTouches(for: currentTouch)?.last {
                currentTool.moved(touch: predictiveTouch)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            currentTool.ended(touch: touch)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            currentTool.ended(touch: touch)
        }
    }

    func setToolColor(_ color: UIColor) {
        currentTool.toolColor = color
    }

    func setToolWidth(_ width: CGFloat) {
        currentTool.toolWidth = width
    }

    func renderedImage() -> UIImage? {
        return canvas.image
    }
}
