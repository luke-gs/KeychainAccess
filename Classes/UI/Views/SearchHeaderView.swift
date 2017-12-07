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

    /// Image to display inside the rounded imageView.
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
        backgroundColor = UIColor(red: 133.0/255.0, green: 134.0/255.0, blue: 141.0/255.0, alpha: 0.16)
        translatesAutoresizingMaskIntoConstraints = false

        imageView.tintColor = UIColor.white
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 24.0
        imageView.layer.shouldRasterize = true
        imageView.layer.rasterizationScale = traitCollection.currentDisplayScale
        imageView.backgroundColor = #colorLiteral(red: 0.3364340067, green: 0.344623208, blue: 0.3837811649, alpha: 1)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17.0, weight: UIFont.Weight.semibold)
        titleLabel.text = ""
        titleLabel.textColor = #colorLiteral(red: 0.3364340067, green: 0.344623208, blue: 0.3837811649, alpha: 1)
        titleLabel.numberOfLines = 1
        addSubview(titleLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.numberOfLines = 0
        subtitleLabel.font = .systemFont(ofSize: 13.0, weight: UIFont.Weight.regular)
        subtitleLabel.text = ""
        subtitleLabel.textColor = #colorLiteral(red: 0.5212343931, green: 0.5251564384, blue: 0.5512983203, alpha: 1)
        addSubview(subtitleLabel)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
//        searchBar.searchBarStyle = .minimal
        searchBar.barTintColor = UIColor.white
        searchBar.backgroundColor = UIColor.clear
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = "Search"
        addSubview(searchBar)


        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 48.0),
            imageView.widthAnchor.constraint(equalToConstant: 48.0),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 24.0),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24.0),

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
    }

}

extension SearchHeaderView: UISearchBarDelegate {

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchHandler?(searchText)
    }

}
