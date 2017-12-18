//
//  TasksListStatusRowsView.swift
//  MPOLKit
//
//  Created by Kyle May on 18/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class TasksListStatusRowsView: UIView {

    private struct LayoutConstants {
        static let verticalMargin: CGFloat = 16
    }
    
    // MARK: - Views
    
    /// Stack view for resources
    open let resourcesStackView = UIStackView()
    
    // MARK: - Properties
    
    /// Maximum number of views to show in the stack view
    private var maxViews: Int

    // MARK: - Setup
    
    public override init(frame: CGRect) {
        self.maxViews = 0
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    public init(frame: CGRect = .zero, maxViews: Int) {
        self.maxViews = maxViews
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Creates and styles views
    private func setupViews() {
        resourcesStackView.axis = .vertical
        resourcesStackView.alignment = .top
        resourcesStackView.spacing = 10
        resourcesStackView.distribution = .fill
        resourcesStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(resourcesStackView)
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            resourcesStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: LayoutConstants.verticalMargin),
            resourcesStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            resourcesStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            resourcesStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    // MARK: - Config
    
    open func setStatusRows(_ viewModels: [TasksListItemStatusRowViewModel]?) {
        resourcesStackView.removeArrangedSubviewsFromViewHeirachy()
        
        guard let viewModels = viewModels, viewModels.count > 0 else {
            return
        }
        
        // Add first (max) view models
        for viewModel in viewModels[0..<min(maxViews, viewModels.count)] {
            let statusRow = TasksListCellStatusRow()
            statusRow.imageView.image = viewModel.image?.withRenderingMode(.alwaysTemplate)
            statusRow.imageView.tintColor = viewModel.tintColor ?? .secondaryGray
            statusRow.titleLabel.text = viewModel.resourceTitle
            statusRow.titleLabel.textColor = viewModel.tintColor ?? .secondaryGray
            statusRow.subtitleLabel.text = viewModel.statusText
            statusRow.subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: viewModel.useBoldStatusText ? .semibold : .regular)
            statusRow.subtitleLabel.textColor = viewModel.tintColor ?? .secondaryGray
            resourcesStackView.addArrangedSubview(statusRow)
        }
        
        // Add spacer view if less than max views
        if resourcesStackView.arrangedSubviews.count < maxViews + 1 {
            resourcesStackView.addArrangedSubview(UIView())
        }
    }
}
