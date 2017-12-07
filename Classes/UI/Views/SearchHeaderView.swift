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

    private var imageView: UIImageView = UIImageView(image: AssetManager.shared.image(forKey: .edit))
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
        backgroundColor = UIColor.primaryGray
        translatesAutoresizingMaskIntoConstraints = false

        let circleView = UIView()
        circleView.backgroundColor = #colorLiteral(red: 0.3364340067, green: 0.344623208, blue: 0.3837811649, alpha: 1)
        circleView.clipsToBounds = true
        circleView.layer.cornerRadius = 24.0
        circleView.layer.shouldRasterize = true
        circleView.layer.rasterizationScale = traitCollection.currentDisplayScale
        circleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(circleView)

        imageView.tintColor = UIColor.white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17.0, weight: UIFont.Weight.semibold)
        titleLabel.textColor = UIColor.primaryGray
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
            circleView.heightAnchor.constraint(equalToConstant: imageWidth),
            circleView.widthAnchor.constraint(equalToConstant: imageWidth),
            circleView.topAnchor.constraint(equalTo: self.topAnchor, constant: halfWidth),
            circleView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: halfWidth),

            imageView.topAnchor.constraint(equalTo: circleView.topAnchor, constant: quarterWidth),
            imageView.leadingAnchor.constraint(equalTo: circleView.leadingAnchor, constant: quarterWidth),
            imageView.bottomAnchor.constraint(equalTo: circleView.bottomAnchor, constant: -quarterWidth),
            imageView.trailingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: -quarterWidth),

            titleLabel.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 16.0),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24.0),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 28.0),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),

            searchBar.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20.0),
            searchBar.leadingAnchor.constraint(equalTo: circleView.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -24.0),
            searchBar.heightAnchor.constraint(equalToConstant: 32.0)

            ])
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
