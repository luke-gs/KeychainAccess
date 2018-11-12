//
//  PatrolAnnotationView.swift
//  MPOLKit
//
//  Created by Kyle May on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MapKit
import PatternKit

/// Annotation view for a patrol, bubble view with a simple text label
open class PatrolAnnotationView: BubbleAnnotationView {

    // MARK: - Constants

    private struct LayoutConstants {
        static let priorityIconWidth: CGFloat = 24
        static let priorityIconHeight: CGFloat = 16
        static let priorityIconTextMargin: CGFloat = 4

        static let smallMargin: CGFloat = 4
    }

    // MARK: - Views

    /// Label in the bubble
    private var titleLabel: UILabel!

    // MARK: - Setup

    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    open override func configure(withAnnotation annotation: MKAnnotation, usesDarkBackground: Bool) {
        super.configure(withAnnotation: annotation, usesDarkBackground: usesDarkBackground)

        let titleColor = usesDarkBackground ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0.2, green: 0.2039215686, blue: 0.2274509804, alpha: 1)

        titleLabel.textColor = titleColor
        titleLabel.text = [annotation.title ?? "", annotation.subtitle ?? ""].joined()
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
    }

    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: bubbleContentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: bubbleContentView.leadingAnchor, constant: LayoutConstants.smallMargin),
            titleLabel.trailingAnchor.constraint(equalTo: bubbleContentView.trailingAnchor, constant: -LayoutConstants.smallMargin)
        ])
    }

}
