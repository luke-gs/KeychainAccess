//
//  CollectionViewFormFooterView.swift
//  MPOLKit
//
//  Created by KGWH78 on 27/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


public class CollectionViewFormFooterView: UICollectionReusableView, DefaultReusable {

    // MARK: - Sizing

    public static let minimumHeight: CGFloat = 36.0


    // MARK: - Public properties

    public var text: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue; setNeedsLayout() }
    }

    public override var tintColor: UIColor! {
        get { return super.tintColor }
        set { super.tintColor = newValue }
    }

    // MARK: - Private properties

    private let titleLabel = UILabel(frame: .zero)

    private var indexPath: IndexPath?

    private var isRightToLeft: Bool = false {
        didSet {
            if isRightToLeft == oldValue {
                return

            }
        }
    }

    // MARK: - Initializers

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
        isAccessibilityElement = true
        preservesSuperviewLayoutMargins = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = tintColor
        titleLabel.font = .systemFont(ofSize: 11.0, weight: UIFontWeightLight)

        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor)
        ])
    }

    // MARK: - Overrides

    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        indexPath = layoutAttributes.indexPath
        layoutMargins = (layoutAttributes as? CollectionViewFormLayoutAttributes)?.layoutMargins ?? UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    }

    public final override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
    }

    public override var semanticContentAttribute: UISemanticContentAttribute {
        didSet { isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft }
    }

    public override func tintColorDidChange() {
        super.tintColorDidChange()
        titleLabel.textColor = tintColor
    }

    // MARK: - Accessibility

    open override var accessibilityLabel: String? {
        get { return super.accessibilityLabel?.ifNotEmpty() ?? titleLabel.text }
        set { super.accessibilityLabel = newValue }
    }

}
