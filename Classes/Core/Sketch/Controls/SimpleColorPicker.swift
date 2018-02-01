//
//  SimpleColorPicker.swift
//  MPOLKit
//
//  Created by QHMW64 on 15/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class SimpleColorPicker: UIView, ColorPickable {

    static let circleDiameter: CGFloat = 40.0

    private(set) var colors: [UIColor] = []

    var colorSelectionHandler: ((UIColor) -> ())?
    private var buttons: [UIButton] = []
    private var selectedColorButton: UIButton? {
        didSet {
            if selectedColorButton == oldValue {
                selectedColorButton?.shake()
                return
            }

            self.resetCircle(oldValue)
            UIView.animate(withDuration: 0.3) {
                self.selectedColorButton?.setImage(self.outlinedCircle(around: self.selectedColorButton?.imageView?.image), for: .normal)
            }
            self.selectedColorButton?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
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
        MPLCodingNotSupported()
    }

    func set(_ color: UIColor) {
        if let index = colors.index(where: { $0.isEqual(color) }) {
            selectedColorButton = buttons[index]
            colorSelectionHandler?(color)
        }
    }

    private func resetCircle(_ view: UIButton?) {
        guard let view = view else { return }
        view.transform = CGAffineTransform.identity
        UIView.animate(withDuration: 0.1) {
            if let index = self.buttons.index(of: view) {
                view.setImage(UIImage.circle(diameter: SimpleColorPicker.circleDiameter, color: self.colors[index]), for: .normal)
            }
        }
    }

    private func outlinedCircle(around image: UIImage?) -> UIImage? {
        guard let image = image else { return nil }
        let size = CGSize(width: image.size.width + 10, height: image.size.height + 10)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        image.draw(in: CGRect(origin: CGPoint(x: 5, y: 5), size: image.size))

        context.setStrokeColor(UIColor.darkGray.cgColor)
        context.setLineWidth(1.0)
        context.strokeEllipse(in: CGRect(origin: CGPoint(x: 2.5, y: 2.5), size: CGSize(width: size.width - 5, height: size.height - 5)))
        let outlinedImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return outlinedImage
    }

    private func commonInit() {
        buttons = colors.enumerated().map {
            let button = UIButton(type: .custom)
            button.setImage(UIImage.circle(diameter: SimpleColorPicker.circleDiameter, color: $0.element), for: .normal)
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
        selectedColorButton = button
        colorSelectionHandler?(colors[button.tag])
    }
}

fileprivate extension UIColor {
    func isEqual(_ object: UIColor) -> Bool {
        return self.cgColor == object.cgColor
    }
}
