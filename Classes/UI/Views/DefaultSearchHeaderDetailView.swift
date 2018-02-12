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

    public init(title: String?, subtitle: String?, image: ImageLoadable?) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }
}

public class DefaultSearchHeaderDetailView: UIView, SearchHeaderUpdateable {

    public func update(with title: String? = nil, subtitle: String? = nil, image: ImageLoadable? = nil) {
        titleLabel.text = title ?? titleLabel.text
        subtitleLabel.text = subtitle ?? subtitleLabel.text
        self.image = image?.sizing().image ?? self.image
    }
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

    private var imageView: UIImageView = UIImageView()

    private let imageWidth: CGFloat = 48.0

    // MARK: - Initializers
    public init(configuration: SearchHeaderConfiguration) {
        super.init(frame: .zero)

        titleLabel.text = configuration.title
        subtitleLabel.text = configuration.subtitle
        defer {
            image = configuration.image?.sizing().image
        }

        commonInit()
    }

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

        let image = AssetManager.shared.image(forKey: .edit)?
            .withCircleBackground(tintColor: UIColor.white,
                                  circleColor: UIColor.primaryGray,
                                  style: .auto(padding:  CGSize(width: 14, height: 14),
                                               shrinkImage: true)
        )
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

        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: imageWidth),
            imageView.widthAnchor.constraint(equalToConstant: imageWidth),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16.0),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24.0),
            titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
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
        backgroundColor = theme.color(forKey: .searchFieldBackground)

        titleLabel.textColor = theme.color(forKey: .headerTitleText)
        subtitleLabel.textColor = theme.color(forKey: .headerSubtitleText)
    }

}
