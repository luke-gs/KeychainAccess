//
//  SketchControlPanel.swift
//  MPOLKit
//
//  Created by QHMW64 on 12/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

protocol SketchControlPanelDelegate: class {
    func controlPanel(_ panel: SketchControlPanel, didSelectColor color: UIColor)
    func controlPanel(_ panel: SketchControlPanel, didChangeDrawMode mode: SketchMode)
    func controlPanelDidSelectWidth(_ panel: SketchControlPanel)
}

protocol SketchColorPickable {
    var colors: [UIColor] { get }
    var colorPicker: SimpleColorPicker { get }
    func setSelectedColor(_ color: UIColor)
}

class SketchControlPanel: UIView, SketchColorPickable {

    private let penView: PenView = PenView()
    private let eraserView: UIImageView = UIImageView(image: AssetManager.shared.image(forKey: .rubber))
    private(set) var colors: [UIColor] = [.red, .blue, .black]
    private(set) lazy var colorPicker: SimpleColorPicker = SimpleColorPicker(colors: colors)
    lazy var pixelWidthView: PixelWidthView = PixelWidthView()

    var penTopConstraint: NSLayoutConstraint?
    var eraserTopConstraint: NSLayoutConstraint?


    weak var delegate: SketchControlPanelDelegate?

    private var selectedView: UIView? {
        didSet {
            if oldValue == selectedView {
                return
            }

            if oldValue == self.eraserView {
                self.eraserTopConstraint?.constant += 25
            } else {
                self.penTopConstraint?.constant += 25
            }
            guard let selectedView = self.selectedView else {
                return
            }
            if selectedView == self.eraserView {
                self.eraserTopConstraint?.constant -= 25
            } else {
                self.penTopConstraint?.constant -= 25
            }

            UIView.animate(withDuration: 0.3) { [unowned self] in
                self.layoutIfNeeded()
            }
        }
    }

    init() {
        super.init(frame: .zero)

        backgroundColor = UIColor.white

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)

        pixelWidthView.selectionHandler = {
            self.delegate?.controlPanelDidSelectWidth(self)
        }
        pixelWidthView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(pixelWidthView)

        penView.translatesAutoresizingMaskIntoConstraints = false
        penView.isUserInteractionEnabled = true
        penView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toolTapped(gesture:))))
        container.addSubview(penView)

        eraserView.translatesAutoresizingMaskIntoConstraints = false
        eraserView.isUserInteractionEnabled = true
        eraserView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toolTapped(gesture:))))
        container.addSubview(eraserView)

        let colorPicker = SimpleColorPicker(colors: colors)
        colorPicker.translatesAutoresizingMaskIntoConstraints = false
        colorPicker.colorSelectionHandler = { [unowned self] color in
            self.setSelectedMode(mode: .draw)
            self.penView.nib.image = self.penView.nib.image?.overlayed(with: color)
            self.delegate?.controlPanel(self, didSelectColor: color)
        }
        container.addSubview(colorPicker)

        // Constraints
        let penTopConstraint = penView.topAnchor.constraint(equalTo: container.topAnchor, constant: -20)
        self.penTopConstraint = penTopConstraint
        let eraserTopConstraint = eraserView.topAnchor.constraint(equalTo: container.topAnchor, constant: -20)
        self.eraserTopConstraint = eraserTopConstraint

        NSLayoutConstraint.activate([

            pixelWidthView.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 8.0),
            pixelWidthView.topAnchor.constraint(equalTo: container.topAnchor),
            pixelWidthView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            penView.leadingAnchor.constraint(equalTo: pixelWidthView.trailingAnchor, constant: 20.0),
            penView.trailingAnchor.constraint(equalTo: eraserView.leadingAnchor, constant: -20.0),
            penTopConstraint,
            eraserTopConstraint,

            colorPicker.leadingAnchor.constraint(equalTo: eraserView.trailingAnchor, constant: 20.0),
            colorPicker.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            colorPicker.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -8.0),

            container.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            container.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            container.centerXAnchor.constraint(equalTo: centerXAnchor),
            container.heightAnchor.constraint(equalTo: heightAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func toolTapped(gesture: UITapGestureRecognizer) {
        if selectedView == gesture.view {
            selectedView?.shake()
            return
        } else {
            selectedView = gesture.view
        }
        delegate?.controlPanel(self, didChangeDrawMode: selectedView == penView ? .draw : .erase)
    }

    func setSelectedMode(mode: SketchMode) {
        switch mode {
        case .draw:
            selectedView = penView
        case .erase:
            selectedView = eraserView
        }
    }

    func setSelectedColor(_ color: UIColor) {
        colorPicker.set(color)
    }
}

fileprivate class PenView: UIView {

    let stub = UIImageView(image: AssetManager.shared.image(forKey: .penStub))
    let nib = UIImageView(image: AssetManager.shared.image(forKey: .penNib))

    init() {
        super.init(frame: .zero)

        isUserInteractionEnabled = true

        stub.translatesAutoresizingMaskIntoConstraints = false
        stub.isUserInteractionEnabled = true
        addSubview(stub)

        nib.translatesAutoresizingMaskIntoConstraints = false
        nib.isUserInteractionEnabled = true
        addSubview(nib)

        NSLayoutConstraint.activate([
            nib.topAnchor.constraint(equalTo: stub.topAnchor),
            nib.centerXAnchor.constraint(equalTo: stub.centerXAnchor),

            stub.leadingAnchor.constraint(equalTo: leadingAnchor),
            stub.centerXAnchor.constraint(equalTo: centerXAnchor),
            stub.topAnchor.constraint(equalTo: topAnchor, constant: -20.0)
        ])
    }

    override var intrinsicContentSize: CGSize {
        return stub.frame.size
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIView {
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.06
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: frame.midX, y: frame.midY - 3)
        animation.toValue = CGPoint(x: frame.midX, y: frame.midY + 3)
        layer.add(animation, forKey: "position")
    }
}

extension UIImage {

    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()

        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)

        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return img
    }

    // Overlay the image with given color
    // white will stay white and black will stay black as the lightness of the image is preserved
    func overlayed(with color: UIColor) -> UIImage? {

        return modifiedImage { context, rect in

            context.setBlendMode(.overlay)
            color.setFill()
            context.fill(rect)

            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }

    private func modifiedImage( draw: (CGContext, CGRect) -> ()) -> UIImage? {

        // using scale correctly preserves retina images
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext = UIGraphicsGetCurrentContext()!

        // correctly rotate image
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)

        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)

        draw(context, rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}
