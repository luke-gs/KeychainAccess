//
//  CustomisableSearchHeaderView.swift
//  MPOLKit
//
//  Created by QHMW64 on 12/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol SearchHeaderUpdateable {
    func update(with title: String?, subtitle: String?, image: ImageLoadable?)
}

public class CustomisableSearchHeaderView: UIView, UISearchBarDelegate {

    public var displayView: (UIView & SearchHeaderUpdateable)?
    public let searchBar: UISearchBar = UISearchBar(frame: .zero)

    public var searchHandler: ((String) -> Void)?

    public init(displayView: (UIView & SearchHeaderUpdateable)) {
        self.displayView = displayView
        super.init(frame: .zero)

        addSubview(displayView)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        searchBar.barTintColor = UIColor.white
        searchBar.backgroundColor = UIColor.clear
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = NSLocalizedString("Search", comment: "Search Text Placeholder")
        addSubview(searchBar)

        let searchBarIntrisicInset: CGFloat = 8.0
        let horizontalInset: CGFloat = 24.0

        var constraints: [NSLayoutConstraint] = [
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalInset),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalInset),
            searchBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24.0),
            searchBar.heightAnchor.constraint(equalToConstant: 32.0)
        ]
        if let displayView = displayView {
            displayView.translatesAutoresizingMaskIntoConstraints = false
            constraints.append(contentsOf: [
                displayView.topAnchor.constraint(equalTo: topAnchor, constant: 24.0),
                displayView.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: searchBarIntrisicInset),
                displayView.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: -searchBarIntrisicInset),

                searchBar.topAnchor.constraint(equalTo: displayView.bottomAnchor, constant: 16)
                ])
        } else {
            searchBar.topAnchor.constraint(equalTo: topAnchor, constant: 12.0)
        }

        NSLayoutConstraint.activate(constraints)

        NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
        apply(ThemeManager.shared.theme(for: .current))
    }


    // MARK: - Theme

    @objc private func interfaceStyleDidChange() {
        apply(ThemeManager.shared.theme(for: .current))
    }

    private func apply(_ theme: Theme) {
        backgroundColor = theme.color(forKey: .searchFieldBackground)
        searchBar.textField?.backgroundColor = theme.color(forKey: .searchField)
    }

    // MARK: - Search Bar Delegate

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchHandler?(searchText)
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }

}
