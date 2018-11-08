//
//  IncidentAnnotationView.swift
//  MPOLKit
//
//  Created by Kyle May on 2/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit

/// Annotation view for an incident, bubble view with a priority badge and a combined title/subtitle label
open class IncidentAnnotationView: BubbleAnnotationView {

    // MARK: - Constants

    private struct LayoutConstants {
        static let priorityIconWidth: CGFloat = 24
        static let priorityIconHeight: CGFloat = 16
        static let priorityIconTextMargin: CGFloat = 4

        static let smallMargin: CGFloat = 4
    }

    // MARK: - Views

    /// Top line label in the bubble
    public private(set) var titleLabel: UILabel!

    /// Rounded rect showing the priority level colour
    private var priorityBackground: UIView!

    /// Label inside priority rect showing the priority level text
    private var priorityLabel: UILabel!

    // MARK: - Setup

    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    public func configure(withAnnotation annotation: MKAnnotation, priorityText: String, priorityTextColor: UIColor, priorityFillColor: UIColor, priorityBorderColor: UIColor, usesDarkBackground: Bool) {
        super.configure(withAnnotation: annotation, usesDarkBackground: usesDarkBackground)

        let titleColor = usesDarkBackground ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0.2, green: 0.2039215686, blue: 0.2274509804, alpha: 1)

        titleLabel.textColor = titleColor
        titleLabel.text = [annotation.title ?? "", annotation.subtitle ?? ""].joined()
        priorityLabel.text = priorityText

        priorityBackground.backgroundColor = priorityFillColor
        priorityBackground.layer.borderColor = priorityBorderColor.cgColor
        priorityLabel.textColor = priorityTextColor
    }

    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    /// Creates and styles views
    private func setupViews() {
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.semibold)
        titleLabel.textColor = #colorLiteral(red: 0.337254902, green: 0.3450980392, blue: 0.3803921569, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleContentView.addSubview(titleLabel)

        priorityBackground = UIView()
        priorityBackground.layer.cornerRadius = 4
        priorityBackground.layer.borderWidth = 1
        priorityBackground.backgroundColor = .gray
        priorityBackground.translatesAutoresizingMaskIntoConstraints = false
        bubbleContentView.addSubview(priorityBackground)

        priorityLabel = UILabel()
        priorityLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.bold)
        priorityLabel.textAlignment = .center
        priorityLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleContentView.addSubview(priorityLabel)
    }

    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: bubbleContentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: priorityBackground.trailingAnchor, constant: LayoutConstants.smallMargin),
            titleLabel.trailingAnchor.constraint(equalTo: bubbleContentView.trailingAnchor),

            priorityBackground.centerYAnchor.constraint(equalTo: bubbleContentView.centerYAnchor),
            priorityBackground.leadingAnchor.constraint(equalTo: bubbleContentView.leadingAnchor),
            priorityBackground.widthAnchor.constraint(equalToConstant: LayoutConstants.priorityIconWidth),
            priorityBackground.heightAnchor.constraint(equalToConstant: LayoutConstants.priorityIconHeight),

            priorityLabel.topAnchor.constraint(equalTo: priorityBackground.topAnchor, constant: LayoutConstants.priorityIconTextMargin),
            priorityLabel.leadingAnchor.constraint(equalTo: priorityBackground.leadingAnchor, constant: LayoutConstants.priorityIconTextMargin),
            priorityLabel.trailingAnchor.constraint(equalTo: priorityBackground.trailingAnchor, constant: -LayoutConstants.priorityIconTextMargin),
            priorityLabel.bottomAnchor.constraint(equalTo: priorityBackground.bottomAnchor, constant: -LayoutConstants.priorityIconTextMargin)
        ])
    }
}
