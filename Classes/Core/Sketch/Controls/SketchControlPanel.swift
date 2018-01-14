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
}

class SketchControlPanel: UIView {

    private let penView: PenView = PenView()
    private let eraserView: UIImageView = UIImageView(image: AssetManager.shared.image(forKey: .rubber))
    private var colors: [UIColor] = [.red, .blue, .green, .black, .yellow]
    private lazy var colorPicker: SimpleColourPicker = SimpleColourPicker(colors: colors)

    weak var delegate: SketchControlPanelDelegate?

    private var selectedView: UIView? {
        didSet {
            UIView.animate(withDuration: 0.3) { [unowned self] in
                if var oldFrame = oldValue?.frame {
                    oldFrame.origin.y += 25.0
                    oldValue?.frame = oldFrame
                }
                guard let selectedView = self.selectedView else {
                    return
                }
                var frame = selectedView.frame
                frame.origin.y -= 25.0
                selectedView.frame = frame
            }
        }
    }

    init() {
        super.init(frame: .zero)

        backgroundColor = UIColor.white

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)

        penView.translatesAutoresizingMaskIntoConstraints = false
        penView.isUserInteractionEnabled = true
        penView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toolTapped(gesture:))))
        container.addSubview(penView)

        eraserView.translatesAutoresizingMaskIntoConstraints = false
        eraserView.isUserInteractionEnabled = true
        eraserView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toolTapped(gesture:))))
        container.addSubview(eraserView)

        let colorPicker = SimpleColourPicker(colors: colors)
        colorPicker.translatesAutoresizingMaskIntoConstraints = false
        colorPicker.colorSelectionHandler = { [unowned self] color in
            self.setSelectedMode(mode: .draw)
            self.penView.nib.image = self.penView.nib.image?.overlayed(with: color)
            self.delegate?.controlPanel(self, didSelectColor: color)
        }
        container.addSubview(colorPicker)

        NSLayoutConstraint.activate([
            penView.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 8.0),
            penView.trailingAnchor.constraint(equalTo: eraserView.leadingAnchor, constant: -20.0),
            penView.topAnchor.constraint(equalTo: container.topAnchor),

            eraserView.topAnchor.constraint(equalTo: container.topAnchor, constant: -20),

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

class SimpleColourPicker: UIView {

    private(set) var colors: [UIColor] = []
    var colorSelectionHandler: ((UIColor) -> ())?
    private var buttons: [UIButton] = []
    private var selectedColor: UIButton? {
        didSet {

            if selectedColor == oldValue {
                selectedColor?.shake()
                return
            }

            UIView.animate(withDuration: 0.3) {
                oldValue?.transform = CGAffineTransform.identity
                self.selectedColor?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
        }
    }

    init(colors: [UIColor]) {
        self.colors = colors
        super.init(frame: .zero)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(_ color: UIColor) {
        if let index = colors.index(of: color) {
            selectedColor = buttons[index]
        }
    }

    private func commonInit() {
        buttons = colors.enumerated().map {
            let button = UIButton(type: .custom)
            button.setImage(UIImage.circle(diameter: 40.0, color: $0.element), for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
            button.tag = $0.offset
            return button
        }

        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: safeAreaOrFallbackLeadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: safeAreaOrFallbackTrailingAnchor),
            stackView.topAnchor.constraint(equalTo: safeAreaOrFallbackTopAnchor),
            stackView.bottomAnchor.constraint(equalTo: safeAreaOrFallbackBottomAnchor),
        ])
    }

    @objc private func buttonTapped(button: UIButton) {
        selectedColor = button
        colorSelectionHandler?(colors[button.tag])
    }
}


fileprivate extension UIView {
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

class PenView: UIView {

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

