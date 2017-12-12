//
//  HeaderFormItem.swift
//  Alamofire
//
//  Created by KGWH78 on 19/9/17.
//

import Foundation


public class HeaderFormItem: BaseSupplementaryFormItem {

    public enum HeaderFormItemStyle {
        case plain
        case collapsible
    }

    public var text: String?

    public var isExpanded: Bool = true

    public var separatorColor: UIColor?

    public var style: HeaderFormItemStyle = .plain

    public var actionButton: UIButton?

    private var actionButtonHandler: (() -> Void)?

    public init() {
        super.init(viewType: CollectionViewFormHeaderView.self, kind: UICollectionElementKindSectionHeader, reuseIdentifier: CollectionViewFormHeaderView.defaultReuseIdentifier)
    }

    public convenience init(text: String? = nil, style: HeaderFormItemStyle = .plain) {
        self.init()
        self.text = text
        self.style = style
    }

    public override func configure(_ view: UIView) {
        let view = view as! CollectionViewFormHeaderView

        switch style {
        case .plain:
            view.showsExpandArrow = false
            view.isExpanded = true
        case .collapsible:
            view.showsExpandArrow = true
            view.isExpanded = isExpanded
        }

        view.text = text

        // Set or remove action button
        view.actionButton = actionButton
    }

    public override func intrinsicHeight(in collectionView: UICollectionView, layout: CollectionViewFormLayout, for traitCollection: UITraitCollection) -> CGFloat {
        return CollectionViewFormHeaderView.minimumHeight
    }

    public override func apply(theme: Theme, toView view: UICollectionReusableView) {
        let view = view as! CollectionViewFormHeaderView

        let separatorColor = self.separatorColor ?? theme.color(forKey: .separator)
        let secondaryTextColor = theme.color(forKey: .secondaryText)
        let tintColor = theme.color(forKey: .tint)

        view.tintColor = secondaryTextColor
        view.separatorColor = separatorColor

        actionButton?.setTitleColor(tintColor, for: .normal)
        actionButton?.setTitleColor(tintColor?.withAlphaComponent(0.5), for: .highlighted)
    }
}

// MARK: - Chaining methods

extension HeaderFormItem {

    @discardableResult
    public func text(_ text: String?) -> Self {
        self.text = text
        return self
    }

    @discardableResult
    public func isExpanded(_ expanded: Bool) -> Self {
        self.isExpanded = expanded
        return self
    }

    @discardableResult
    public func separatorColor(_ color: UIColor?) -> Self {
        self.separatorColor = color
        return self
    }

    @discardableResult
    public func style(_ style: HeaderFormItemStyle) -> Self {
        self.style = style
        return self
    }

    @discardableResult
    public func actionButton(title: String, handler: @escaping (() -> Void)) -> Self {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        button.contentEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
        button.addTarget(self, action: #selector(actionButtonTapped(button:)), for: .touchUpInside)
        self.actionButton = button
        self.actionButtonHandler = handler
        return self
    }

    @objc private func actionButtonTapped(button: UIButton) {
        actionButtonHandler?()
    }

}
