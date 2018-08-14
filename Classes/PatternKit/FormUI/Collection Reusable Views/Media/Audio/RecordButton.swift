//
//  RecordButton.swift
//  MPOLKit
//
//  Created by QHMW64 on 1/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

internal class RecordButton: UIButton {

    private let outerStrokeWidth: CGFloat = 6.0
    private lazy var shapeLayer: CAShapeLayer = CAShapeLayer()

    var innerPath: UIBezierPath {
        if isSelected {
            let halfWidth = frame.width * 0.5
            let inset = frame.width * 0.25
            return UIBezierPath(roundedRect: CGRect(x: inset, y: inset, width: halfWidth, height: halfWidth), cornerRadius: 4)
        } else {
            // 10 - inset of outerRing + spacing
            let circleWidth = frame.width - outerStrokeWidth - 10.0
            let inset = outerStrokeWidth + 2.0 // Spacing

            // Use rect instead of circle to get better morphing animation.
            return UIBezierPath(roundedRect: CGRect(x: inset, y: inset, width: circleWidth, height: circleWidth), cornerRadius: circleWidth * 0.5)
        }
    }

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func draw(_ rect: CGRect) {

        let context = UIGraphicsGetCurrentContext()!

        let outerRing = UIBezierPath(ovalIn: rect.insetBy(dx: 3, dy: 3))

        context.addPath(outerRing.cgPath)
        context.setLineWidth(outerStrokeWidth)
        context.setStrokeColor(UIColor.white.cgColor)
        context.strokePath()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        shapeLayer.path = innerPath.cgPath
    }

    override var isSelected: Bool {
        didSet {
            //change the inner shape to match the state
            let morph = CABasicAnimation(keyPath: "path")
            morph.duration = 0.4

            //change the shape according to the current state of the control
            morph.toValue = innerPath.cgPath

            //ensure the animation is not reverted once completed
            morph.fillMode = kCAFillModeForwards
            morph.isRemovedOnCompletion = false

            //add the animation
            shapeLayer.add(morph, forKey:"morph")
        }
    }

    private func commonInit() {
        shapeLayer.strokeColor = nil
        shapeLayer.fillColor = UIColor.red.cgColor

        layer.addSublayer(shapeLayer)

        addTarget(self, action: #selector(touchUpInside(sender:)), for: .touchUpInside)
    }

    @objc private func touchUpInside(sender: UIButton) {
        //change the state of the control to update the shape
        isSelected = !isSelected
    }
}
