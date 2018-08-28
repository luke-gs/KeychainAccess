//
//  TextAccessory.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Item Accessorisable that contains text as passed in the initialiser.
open class RoundedLabelAccessory: ItemAccessorisable {
    public var size: CGSize
    public var labelView: RoundedLabelAccessoryView

    public func view() -> UIView {
        return labelView
    }

    open func apply(theme: Theme, toView view: UIView) {
    }

    /// A specific frame can be supplied in addition to text, but a default is used if one is not specified.
    public init(text: String, frame: CGRect = CGRect(x: 0, y: 0, width: 72, height: 30)) {
        labelView = RoundedLabelAccessoryView(text: text, frame: frame)
        size = labelView.frame.size
    }
}

/// View used for TextAccessory.
public class RoundedLabelAccessoryView: UIView {
    var label: UILabel

    public init (text: String, frame: CGRect) {
        label = UILabel(frame: frame)
        super.init(frame: frame)
        label.text = text
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = label.frame.size.height / 2.0
        label.backgroundColor = UIColor.disabledGray
        addSubview(label)
    }

    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
}
