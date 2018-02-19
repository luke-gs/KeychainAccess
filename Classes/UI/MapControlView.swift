//
//  MapControlView.swift
//  MPOLKit
//
//  Created by Herli Halim on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

public enum MapControlOrientation {
    // Layout items from top to bottom.
    case vertical
    // Layout items from left to right.
    case horizontal
}

// This class is just a wrapper to the rounded corner buttons bar,
// similar to the one that's in the Apple Maps.
// Name is hard, so for now, this is the name.
public class MapControlView: UIView {

    /// Default to `8.0`
    public var cornerRadius: CGFloat {
        get {
            return backgroundView.layer.cornerRadius
        }
        set {
            backgroundView.layer.cornerRadius = newValue
            setBorderPath(with: bounds, cornerRadius: newValue)
        }
    }

    /// Default to `UIBlurEffect(style: .extraLight)`.
    /// This property is null resettable.
    public var visualEffect: UIVisualEffect! {
        get {
            return backgroundView.effect
        }
        set {
            let value: UIVisualEffect
            if newValue != nil {
                value = newValue
            } else {
                value = UIBlurEffect(style: .extraLight)
            }
            backgroundView.effect = value
        }
    }

    private var _orientation: MapControlOrientation = .vertical

    /// Default to `.vertical`.
    public var orientation: MapControlOrientation {
        get {
            return _orientation
        }
        set {
            set(orientation: newValue, animated: false)
        }
    }

    /// Default to `UIColor(white: 0.67, alpha: 0.7)`.
    /// This property is null resettable.
    public var separatorColor: UIColor! {
        get {
            return separatorView.separatorColor
        }
        set {
            let value: UIColor
            if let newValue = newValue {
                value = newValue
            } else {
                value = UIColor(white: 0.67, alpha: 0.7)
            }
            borderLayer.strokeColor = value.cgColor
            separatorView.separatorColor = value
        }
    }

    private let separatorView: MapControlSeparatorView
    private var backgroundView: UIVisualEffectView!
    private let stackView: UIStackView
    private let buttons: [UIButton]

    private let borderLayer: CAShapeLayer

    public init(buttons: [UIButton]) {

        precondition(buttons.count > 0, "There should be at least one item.")

        self.buttons = buttons

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView = stackView

        let separatorView = MapControlSeparatorView(views: buttons)
        separatorView.isUserInteractionEnabled = false
        separatorView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        self.separatorView = separatorView

        borderLayer = CAShapeLayer()
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 1.0 / UIScreen.main.scale

        super.init(frame: .zero)

        backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        backgroundView.frame = bounds
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 8.0
        backgroundView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]

        addSubview(backgroundView)
        backgroundView.contentView.addSubview(separatorView)
        backgroundView.contentView.addSubview(stackView)
        layer.addSublayer(borderLayer)

        // Shadow should probably be pre-rendered and rasterised.
        layer.shadowRadius = 4.0
        layer.shadowColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowOpacity = 0.2

        super.backgroundColor = .clear
        separatorColor = nil

        stackView.axis = stackViewAxis(for: orientation)

        buttons.forEach {
            stackView.addArrangedSubview($0)

            $0.widthAnchor.constraint(equalToConstant: _buttonSize).isActive = true
            $0.heightAnchor.constraint(equalToConstant: _buttonSize).isActive = true
        }

        NSLayoutConstraint.activate([
            self.leftAnchor.constraint(equalTo: stackView.leftAnchor),
            self.rightAnchor.constraint(equalTo: stackView.rightAnchor),
            self.topAnchor.constraint(equalTo: stackView.topAnchor),
            self.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        ])
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: - Override
    public override func layoutSubviews() {
        super.layoutSubviews()
        setBorderPath(with: bounds, cornerRadius: cornerRadius)
    }

    public override var intrinsicContentSize: CGSize {
        return sizeThatFits(UILayoutFittingCompressedSize)
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: _buttonSize, height: _buttonSize * CGFloat(buttons.count))
    }

    public override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set {
            // Do nothing, disallow changing background color
            // directly on this class.
        }
    }

    // MARK: - Implementations

    public func set(orientation: MapControlOrientation, animated: Bool = false) {
        _orientation = orientation

        // Yes, this is how much effort it is to make this thing animate nicely...
        if animated {
            let duration = 0.3
            let lastIndex = buttons.count - 1
            let buttonsExcludingLast = buttons[..<lastIndex]

            let separatorView = self.separatorView
            let stackView = self.stackView
            let borderLayer = self.borderLayer

            // Bonus effort to disable implicit animation on border.
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            borderLayer.isHidden = true
            CATransaction.commit()

            UIView.animate(withDuration: duration, delay: 0.0, options: [ .curveEaseOut ], animations: {
                buttonsExcludingLast.forEach({
                    $0.isHidden = true
                    $0.alpha = 0.0

                })
                separatorView.alpha = 0.0

                stackView.setNeedsLayout()
                stackView.layoutIfNeeded()
            }).then { _ -> Promise<Bool> in

                stackView.axis = self.stackViewAxis(for: orientation)
                separatorView.orientation = orientation
                stackView.setNeedsLayout()
                stackView.layoutIfNeeded()

                separatorView.alpha = 1.0

                return UIView.animate(withDuration: duration, delay: 0.0, options:[ .curveEaseOut ], animations: {
                    buttonsExcludingLast.forEach({
                        $0.isHidden = false
                        $0.alpha = 1.0
                    })
                    stackView.setNeedsLayout()
                    stackView.layoutIfNeeded()
                })
            }.then { _ -> Void in
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                borderLayer.isHidden = false
                CATransaction.commit()
            }
        }
    }

    // MARK: - Private methods

    private func setBorderPath(with rect: CGRect, cornerRadius: CGFloat) {
        borderLayer.path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
    }

    private func stackViewAxis(for orientation: MapControlOrientation) -> UILayoutConstraintAxis {
        switch orientation {
        case .horizontal:
            return .horizontal
        case .vertical:
            return .vertical
        }
    }

}

// Would have been 44, but to not scare James, make it 45.
fileprivate var _buttonSize: CGFloat = 45

private class MapControlSeparatorView: UIView {

    let toBeSeparatedViews: [UIView]

    var orientation: MapControlOrientation = .vertical {
        didSet {
            setNeedsDisplay()
        }
    }

    var separatorColor: UIColor = UIColor(white: 0.67, alpha: 0.7) {
        didSet {
            setNeedsDisplay()
        }
    }

    init(views: [UIView]) {
        toBeSeparatedViews = views

        super.init(frame: .zero)

        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func draw(_ rect: CGRect) {

        let separatorWidth = 1 / UIScreen.main.scale
        let xMax = rect.maxX
        let yMax = rect.maxY

        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(separatorWidth)
            separatorColor.setStroke()

            // No need to separate last button.
            let lastIndex = toBeSeparatedViews.count - 1
            let viewsExcludingLast = toBeSeparatedViews[..<lastIndex]

            for view in viewsExcludingLast {
                let from, to: CGPoint

                let frame = view.convert(view.bounds, to: self)
                switch orientation {
                case .vertical:
                    let y = frame.maxY + separatorWidth
                    from = CGPoint(x: 0, y: y)
                    to = CGPoint(x: xMax, y: y)
                case .horizontal:
                    let x = frame.maxX + separatorWidth
                    from = CGPoint(x: x, y: 0)
                    to = CGPoint(x: x, y: yMax)
                }

                context.move(to: from)
                context.addLine(to: to)
                context.strokePath()
            }
        }

    }
}
