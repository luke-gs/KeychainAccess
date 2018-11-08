//
//  TasksListBasicSummaryView.swift
//  MPOLKit
//
//  Created by Kyle May on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import CoreKit
/// A view for the tasks list summary containing a title, subtitle, and caption label
open class TasksListBasicSummaryView: UIView {

    private struct LayoutConstants {
        static let margin: CGFloat = 16
    }

    /// Label for the title
    public let titleLabel = UILabel()

    /// Label for the location
    public let subtitleLabel = UILabel()

    /// Label for the identifier
    public let captionLabel = UILabel()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    /// Creates and styles views
    private func setupViews() {
        titleLabel.font = .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        subtitleLabel.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subtitleLabel)

        captionLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.regular)
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(captionLabel)
    }

    /// Activates view constraints
    private func setupConstraints() {
        titleLabel.setContentHuggingPriority(.required, for: .vertical)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: LayoutConstants.margin),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),

            captionLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 6),
            captionLabel.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),
            captionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                                        constant: -LayoutConstants.margin),
            captionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}
