//
//  TasksListDetailView.swift
//  MPOLKit
//
//  Created by Kyle May on 18/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class TasksListDetailView: UIView {
    
    private struct LayoutConstants {
        static let verticalMargin: CGFloat = 16
    }
    
    // MARK: - Views
    
    /// The label for the middle details section of the cell where space is available
    open let detailLabel = UILabel()

    // MARK: - Setup
    
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
        detailLabel.textColor = .secondaryGray
        detailLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        detailLabel.numberOfLines = 3
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(detailLabel)
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        detailLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        NSLayoutConstraint.activate([
            detailLabel.topAnchor.constraint(equalTo: self.topAnchor,
                                             constant: LayoutConstants.verticalMargin),
            detailLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            detailLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                                constant: -LayoutConstants.verticalMargin),
        ])
    }

}
