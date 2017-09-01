//
//  HorizontalSidebarCell.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 31/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class HorizontalSidebarCell: UIView {

    /// The callback handler for selection
    public var selectHandler : (() -> Void)?

    private(set) var itemButton: UIButton!

    public override init(frame: CGRect) {
        super.init(frame: frame)

        // For now, just a button
        itemButton = UIButton()
        itemButton.translatesAutoresizingMaskIntoConstraints = false
        itemButton.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        self.addSubview(itemButton)

        NSLayoutConstraint.activate([
            itemButton.topAnchor.constraint(equalTo: self.topAnchor),
            itemButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            itemButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            itemButton.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        reloadFonts()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private properties

    private var standardFont: UIFont!
    private var highlightedFont: UIFont!

    private var unselectedTextAttributes: [String: AnyObject] {
        return [NSFontAttributeName: standardFont, NSForegroundColorAttributeName: SidebarTableViewCell.unselectedColor]
    }

    private var selectedTextAttributes: [String: AnyObject] {
        return [NSFontAttributeName: highlightedFont, NSForegroundColorAttributeName: SidebarTableViewCell.selectedColor]
    }

    // MARK: - Updates

    /// Updates the cell with the content of the sidebar item.
    ///
    /// Users should be aware that this does not create a link, and therefore changes to the
    /// sidebar item are not automatically translated to updates within the cell.
    ///
    /// - Parameter item: The `SidebarItem` to configure the cell for.
    open func update(for item: SidebarItem, selected: Bool) {

        itemButton.isEnabled = item.isEnabled
        itemButton.alpha = itemButton.isEnabled ? 1 : 0.2
        itemButton.isSelected = selected

        var text = ""
        if let title = item.title {
            text = item.count > 0 ? "\(item.count) \(title)" : title
        }

        // Set custom colors/fonts by using attributed title on button states
        if selected {
            itemButton.setAttributedTitle(NSAttributedString(string: text, attributes: selectedTextAttributes), for: .normal)
        } else {
            itemButton.setAttributedTitle(NSAttributedString(string: text, attributes: unselectedTextAttributes), for: .normal)
        }
        itemButton.setAttributedTitle(NSAttributedString(string: text, attributes: selectedTextAttributes), for: .selected)
        itemButton.setAttributedTitle(NSAttributedString(string: text, attributes: selectedTextAttributes), for: .highlighted)
    }

    // MARK: - Overrides

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        reloadFonts()
    }

    // MARK: - Private methods

    @objc private func buttonTapped(sender: UIButton) {
        if let selectHandler = selectHandler {
            selectHandler()
        }
    }

    private func reloadFonts() {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline, compatibleWith: traitCollection)
        standardFont = UIFont(descriptor: fontDescriptor, size: fontDescriptor.pointSize - 1)
        if let highlightedDescriptor = fontDescriptor.withSymbolicTraits(.traitBold) {
            highlightedFont = UIFont(descriptor: highlightedDescriptor, size: fontDescriptor.pointSize)
        } else {
            highlightedFont = standardFont
        }
    }
}
