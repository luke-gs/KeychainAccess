//
//  SketchControlPanel.swift
//  MPOLKit
//
//  Created by QHMW64 on 12/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// Basic implementation of a control panel that allows the user to
/// change pen mode, the size of the pen and choose from a selection of
/// 3 colours.
class SketchControlPanel: UIView, SketchColorPickable {

    let colors: [UIColor]
    private let penView: ControlPanelPenView = ControlPanelPenView()
    private let eraserView: UIImageView = UIImageView(image: AssetManager.shared.image(forKey: .rubber))

    lazy var colorPicker: ColorPicker = SimpleColorPicker(colors: colors)
    lazy private(set) var pixelWidthView: PixelWidthView = PixelWidthView()

    // Constraints to manage the animations of the pen and eraser
    // Was using frame based but caused issues when layouts occured
    var penTopConstraint: NSLayoutConstraint?
    var eraserTopConstraint: NSLayoutConstraint?

    weak var delegate: SketchControlPanelDelegate?

    // The current selected view the represents the mode of the control panel
    // Either pen or eraser
    // When this is changed animate the change between the two
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

    init(colors: [UIColor] = [.red, .blue, .darkGray]) {
        self.colors = colors

        super.init(frame: .zero)

        backgroundColor = .white

        let container = UIView()
        container.setContentHuggingPriority(.required, for: .horizontal)

        pixelWidthView.selectionHandler = {
            self.delegate?.controlPanelDidSelectWidth(self)
        }

        penView.isUserInteractionEnabled = true
        penView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toolTapped(gesture:))))

        eraserView.isUserInteractionEnabled = true
        eraserView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toolTapped(gesture:))))

        colorPicker.colorSelectionHandler = { [unowned self] color in
            self.setSelectedMode(mode: .draw)
            self.penView.nib.image = self.penView.nib.image?.overlayed(with: color)
            self.delegate?.controlPanel(self, didSelectColor: color)
        }

        // Constraints
        let penTopConstraint = penView.topAnchor.constraint(equalTo: container.topAnchor, constant: -20)
        self.penTopConstraint = penTopConstraint
        let eraserTopConstraint = eraserView.topAnchor.constraint(equalTo: container.topAnchor, constant: -20)
        self.eraserTopConstraint = eraserTopConstraint

        // Boilerplate constraints
        [container, penView, eraserView, colorPicker, pixelWidthView].forEach { (view: UIView) in
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }

        NSLayoutConstraint.activate([

            pixelWidthView.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 8.0),
            pixelWidthView.widthAnchor.constraint(equalToConstant: 50.0),
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
        MPLCodingNotSupported()
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

    func setSelectedNibSize(_ size: NibSize) {
        pixelWidthView.update(with: size)
    }
}

/// Any UIView is able to "shake", which will cause the view to slightly jiggle
/// in position, drawing attention that something has occurred
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


    /// Returns an image of a circle of a certain diameter and color
    ///
    /// - Parameters:
    ///   - diameter: The diameter of the circle
    ///   - color: The color to draw the circle
    /// - Returns: An image of a circle
    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()

        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)

        ctx.restoreGState()
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }

    /// Overlay the image with given color
    /// white will stay white and black will stay black as the lightness of the image is preserved
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
