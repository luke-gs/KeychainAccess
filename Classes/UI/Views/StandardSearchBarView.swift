//
//  StandardSearchBarView.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 10/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Search bar extension that gives access to search bar text field
extension UISearchBar {
    var textField: UITextField? {
        return allSubviews(of: UITextField.self).first
    }
}

/// Standardized MPOL search bar, that uses theme colors for search bar fill and background
open class StandardSearchBarView: UIView {

    /// Layout sizing constants
    public struct LayoutConstants {
        static let searchBarHeight: CGFloat = 64
    }

    // Actual search bar
    public let searchBar: UISearchBar = UISearchBar(frame: .zero)

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
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundColor = UIColor.clear
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = NSLocalizedString("Search", comment: "Search Text Placeholder")
        searchBar.textField?.backgroundColor = .red
        addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            searchBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: LayoutConstants.searchBarHeight)
        ])

        NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
        apply(ThemeManager.shared.theme(for: .current))
    }

    open override var intrinsicContentSize: CGSize {
        return searchBar.frame.size
    }

    // MARK: - Theme

    @objc private func interfaceStyleDidChange() {
        apply(ThemeManager.shared.theme(for: .current))
    }

    private func apply(_ theme: Theme) {
        searchBar.textField?.backgroundColor = theme.color(forKey: .searchField)
        backgroundColor = theme.color(forKey: .searchFieldBackground)

        // Restore the clear background image, as the changes above remove it!
        searchBar.backgroundImage = UIImage()
    }
}

