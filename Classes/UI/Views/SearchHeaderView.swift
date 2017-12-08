//
//  SearchHeaderView.swift
//  MPOLKit
//
//  Created by Bryan Hathaway on 6/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

open class SearchHeaderView: UIView {

    // MARK: - Public Properties

    /// Image to display inside the circle.
    public var image: UIImage? {
        get {
            return imageView.image
        }

        set {
            imageView.image = newValue?.withRenderingMode(.alwaysTemplate)
        }
    }

    /// The title label.
    public let titleLabel: UILabel = UILabel(frame: .zero)

    /// The subtitle label.
    public let subtitleLabel: UILabel = UILabel(frame: .zero)

    /// Handler that fires when the search text is changed
    public var searchHandler: ((String) -> Void)?

    // MARK: - Private Properties

    private var imageView: UIImageView = UIImageView()
    private let searchBar: UISearchBar = UISearchBar(frame: .zero)

    private let imageWidth: CGFloat = 48.0

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
        translatesAutoresizingMaskIntoConstraints = false

        let image = AssetManager.shared.image(forKey: .edit)?.withCircleBackground(tintColor: UIColor.white,
                                                                                   circleColor: UIColor.primaryGray,
                                                                                   padding: CGSize(width: 14, height: 14),
                                                                                   shrinkImage: true)
        imageView = UIImageView(image: image)
        imageView.tintColor = UIColor.white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17.0, weight: UIFont.Weight.semibold)
        titleLabel.numberOfLines = 1
        addSubview(titleLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.numberOfLines = 1
        subtitleLabel.font = .systemFont(ofSize: 13.0, weight: UIFont.Weight.regular)
        subtitleLabel.textColor = UIColor.secondaryGray
        addSubview(subtitleLabel)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        searchBar.barTintColor = UIColor.white
        searchBar.backgroundColor = UIColor.clear
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = NSLocalizedString("Search", comment: "Search Text Placeholder")
        addSubview(searchBar)

        let halfWidth = imageWidth / 2.0
        let quarterWidth = imageWidth / 4.0

        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: imageWidth),
            imageView.widthAnchor.constraint(equalToConstant: imageWidth),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: halfWidth),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: halfWidth),

            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16.0),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24.0),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 28.0),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),

            searchBar.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20.0),
            searchBar.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -24.0),
            searchBar.heightAnchor.constraint(equalToConstant: 32.0)

            ])

        NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
        apply(ThemeManager.shared.theme(for: .current))
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Theme

    @objc private func interfaceStyleDidChange() {
        apply(ThemeManager.shared.theme(for: .current))
    }

    private func apply(_ theme: Theme) {
        backgroundColor = theme.color(forKey: .headerBackground)?.withAlphaComponent(0.16)
        titleLabel.textColor = theme.color(forKey: .headerTitleText)
        subtitleLabel.textColor = theme.color(forKey: .headerSubtitleText)

    }

}

extension SearchHeaderView: UISearchBarDelegate {

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchHandler?(searchText)
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }

}
