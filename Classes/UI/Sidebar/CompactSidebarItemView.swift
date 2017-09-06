//
//  CompactSidebarItemView.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 31/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Compact size-class version of a view displaying navigation items in a horizontal strip
open class CompactSidebarItemView: UIView {

    private struct ColorConstants {
        public static let selectedColor   = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        public static let unselectedColor = #colorLiteral(red: 0.5450980392, green: 0.568627451, blue: 0.6235294118, alpha: 1)
    }

    /// The callback handler for selection
    public var selectHandler : (() -> Void)?

    private(set) var itemButton: UIButton!

    public override init(frame: CGRect) {
        super.init(frame: frame)

        // For now, just a button
        itemButton = UIButton()
        itemButton.translatesAutoresizingMaskIntoConstraints = false
        itemButton.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        itemButton.contentEdgeInsets = UIEdgeInsetsMake(10, 0, 10, 0)
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

    private var unselectedFont: UIFont!
    private var selectedFont: UIFont!

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

        // Set custom colors/fonts by using attributed title on button states
        var selectedText = NSMutableAttributedString()
        var unselectedText = NSMutableAttributedString()
        var highlightedText = NSMutableAttributedString()
        if item.count > 0 {
            selectedText.append("\(item.count) ", font: selectedFont, color: item.alertColor ?? ColorConstants.selectedColor)
            unselectedText.append("\(item.count) ", font: unselectedFont, color: item.alertColor ?? ColorConstants.unselectedColor)
            highlightedText.append("\(item.count) ", font: unselectedFont, color: ColorConstants.selectedColor)
        }
        if let title = item.title {
            selectedText.append(title, font: selectedFont, color: ColorConstants.selectedColor)
            unselectedText.append(title, font: unselectedFont, color: ColorConstants.unselectedColor)
            highlightedText.append(title, font: unselectedFont, color: ColorConstants.selectedColor)
        }

        itemButton.setAttributedTitle(selected ? selectedText : unselectedText, for: .normal)
        itemButton.setAttributedTitle(selectedText, for: .selected)
        itemButton.setAttributedTitle(highlightedText, for: .highlighted)
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
        unselectedFont = UIFont(descriptor: fontDescriptor, size: fontDescriptor.pointSize - 1)
        if let highlightedDescriptor = fontDescriptor.withSymbolicTraits(.traitBold) {
            selectedFont = UIFont(descriptor: highlightedDescriptor, size: fontDescriptor.pointSize)
        } else {
            selectedFont = unselectedFont
        }
    }
}
