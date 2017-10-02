//
//  FormAccessoryView.swift
//  MPOLKit
//
//  Created by Rod Brown on 3/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public struct AccessoryLabelDetail {
    var text: String?
    var textColour: UIColor?
    var borderColour: UIColor?
    var backgroundColour: UIColor?
    var font: UIFont?

    public init(text: String?,
         textColour: UIColor? = UIColor.darkGray,
         borderColour: UIColor? = .darkGray,
         backgroundColour: UIColor? = .clear,
         font: UIFont? =  UIFont.boldSystemFont(ofSize: 12.0)) {

        self.text = text
        self.textColour = textColour
        self.borderColour = borderColour
        self.backgroundColour = backgroundColour
        self.font = font
    }
}

public enum AccessoryTextStyle {
    case roundedRect(AccessoryLabelDetail)
    case `default`(AccessoryLabelDetail)

    func view() -> UILabel {
        switch self {
        case .default(let details), .roundedRect(let details):
            let label = RoundedRectLabel()
            label.backgroundColor = details.backgroundColour
            label.textColor = details.textColour
            label.borderColor = details.borderColour
            label.text = details.text
            return label
        }
    }

    var decoration: AccessoryLabelDetail {
        switch self {
        case .default(let details), .roundedRect(let details):
            return details
        }
    }
}

public final class FormAccessoryView: UIView {

    fileprivate var label: UILabel?
    fileprivate let imageView: FormAccessoryImageView
    public var labelStyle: AccessoryTextStyle?
    public var style: Style {
        didSet {
            if style != oldValue {
                imageView.image = style.image
            }
        }
    }

    public init(style: Style, labelStyle: AccessoryTextStyle? = nil) {
        self.style = style
        self.labelStyle = labelStyle
        self.imageView = FormAccessoryImageView(style: style)

        super.init(frame: .zero)

        addSubview(imageView)
        if let labelStyle = labelStyle {
            let label = labelStyle.view()
            self.label = label
            addSubview(label)
        }
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = imageView.image?.size ?? .zero
        if let labelStyle = labelStyle {
            let decoration = labelStyle.decoration
            let sizing = StringSizing(string: decoration.text ?? "", font: decoration.font, numberOfLines: 1)
            size.width += sizing.minimumWidth(compatibleWith: traitCollection) + 8.0
            let height = sizing.minimumHeight(inWidth: size.width, compatibleWith: traitCollection)
            size.height = max(label?.frame.height ?? 0.0, size.height) + 8.0
        }
        return size
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if let label = label {
            label.sizeToFit()

            let centerY = bounds.midY

            label.frame.origin = CGPoint(x: 0.0, y: 0.0)
            label.center = CGPoint(x: label.center.x, y: centerY)

            imageView.frame.origin = CGPoint(x: label.frame.maxX + 8.0, y: 0.0)
            imageView.center = CGPoint(x: imageView.center.x, y: centerY)
        }
    }
}
