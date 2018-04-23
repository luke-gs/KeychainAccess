//
//  DefaultSearchHeaderDetailView.swift
//  MPOLKit
//
//  Created by QHMW64 on 12/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public struct SearchHeaderConfiguration {
    public var title: String?
    public var subtitle: String?
    public var image: ImageLoadable?
    public let imageStyle: ImageStyle
    public let tintColor: UIColor?
    public let borderColor: UIColor?

    public init(title: String?, subtitle: String?, image: ImageLoadable?, imageStyle: ImageStyle = .roundedRect, tintColor: UIColor? = .white, borderColor: UIColor? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.imageStyle = imageStyle
        self.tintColor = tintColor
        self.borderColor = borderColor
    }
}

public class DefaultSearchHeaderDetailView: UIView, SearchHeaderUpdateable {


    /// Updating the default search Header View
    /// This method allows you to provide potential new values
    ///
    /// - Parameters:
    ///   - title: A new title to provide to the titleLabel - Nil Resettable
    ///   - subtitle: A new subtitle
    ///   - image: A new image for the header - Nil Resettable
    public func update(with title: String? = nil, subtitle: String? = nil, image: ImageLoadable? = nil) {
        titleLabel.text = title ?? titleLabel.text
        subtitleLabel.text = subtitle
        thumbnailView.imageView.image = image?.sizing().image ?? thumbnailView.imageView.image
    }
    // MARK: - Public Properties

    /// The title label.
    public let titleLabel: UILabel = UILabel(frame: .zero)

    /// The subtitle label.
    public let subtitleLabel: UILabel = UILabel(frame: .zero)

    /// The thumbnailView (bordered image view).
    public let thumbnailView = EntityThumbnailView()

    public var accessoryView: UIView? {
        didSet {
            guard accessoryView != oldValue else { return }
            if let view = accessoryView {

                view.setContentHuggingPriority(.required, for: .horizontal)
                view.translatesAutoresizingMaskIntoConstraints = false
                addSubview(view)

                NSLayoutConstraint.activate([
                    view.trailingAnchor.constraint(equalTo: trailingAnchor),
                    view.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8.0),
                    view.centerYAnchor.constraint(equalTo: centerYAnchor),
                    view.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
                    view.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
                ])
            } else {
                oldValue?.removeFromSuperview()
            }
        }
    }

    // MARK: - Private Properties
    private let imageWidth: CGFloat = 48.0
    public var imageStyle: ImageStyle = .roundedRect {
        didSet {
            thumbnailView.imageView.layer.cornerRadius = imageStyle.cornerRadius(for: thumbnailView.imageView.frame.size)
            setNeedsLayout()
        }
    }

    // MARK: - Initializers
    public init(configuration: SearchHeaderConfiguration) {
        super.init(frame: .zero)

        imageStyle = configuration.imageStyle
        titleLabel.text = configuration.title
        subtitleLabel.text = configuration.subtitle

        configuration.image?.loadImage(completion: { (imageSizable) in
            self.thumbnailView.imageView.image = imageSizable.sizing().image
            self.thumbnailView.imageView.contentMode = imageSizable.sizing().contentMode ?? .center
        })

        if thumbnailView.imageView.image == nil {
            let image = AssetManager.shared.image(forKey: .edit)?
                .withCircleBackground(tintColor: UIColor.white,
                                      circleColor: UIColor.primaryGray,
                                      style: .auto(padding:  CGSize(width: 20, height: 20),
                                                   shrinkImage: false)
            )
            thumbnailView.imageView.image = image
            thumbnailView.imageView.contentMode = .center
        }

        // hide the silver background for non entity images
        if configuration.imageStyle != .entity {
            thumbnailView.backgroundImageView.image = nil
        }

        thumbnailView.imageView.layer.cornerRadius = imageStyle.cornerRadius(for: CGSize(width: imageWidth, height: imageWidth))
        thumbnailView.imageView.clipsToBounds = true
        thumbnailView.imageView.tintColor = configuration.tintColor
        thumbnailView.borderColor = configuration.borderColor ?? nil
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(thumbnailView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17.0, weight: UIFont.Weight.semibold)
        titleLabel.numberOfLines = 1
        addSubview(titleLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.numberOfLines = 1
        subtitleLabel.font = .systemFont(ofSize: 13.0, weight: UIFont.Weight.regular)
        subtitleLabel.textColor = UIColor.secondaryGray
        addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            thumbnailView.heightAnchor.constraint(equalToConstant: imageWidth),
            thumbnailView.widthAnchor.constraint(equalToConstant: imageWidth),
            thumbnailView.topAnchor.constraint(equalTo: topAnchor),
            thumbnailView.leadingAnchor.constraint(equalTo: leadingAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: 16.0),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24.0),
            titleLabel.topAnchor.constraint(equalTo: thumbnailView.topAnchor),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: thumbnailView.bottomAnchor)
        ])

        NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
        apply(ThemeManager.shared.theme(for: .current))
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Theme

    @objc private func interfaceStyleDidChange() {
        apply(ThemeManager.shared.theme(for: .current))
    }

    private func apply(_ theme: Theme) {
        backgroundColor = theme.color(forKey: .searchFieldBackground)

        titleLabel.textColor = theme.color(forKey: .headerTitleText)
        subtitleLabel.textColor = theme.color(forKey: .headerSubtitleText)
    }

}
