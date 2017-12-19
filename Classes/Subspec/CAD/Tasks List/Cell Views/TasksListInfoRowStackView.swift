//
//  TasksListInfoRowStackView.swift
//  MPOLKit
//
//  Created by Kyle May on 18/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class TasksListInfoRowStackView: UIView {

    private struct LayoutConstants {
        static let verticalMargin: CGFloat = 16
    }
    
    // MARK: - Views
    
    /// Stack view for resources
    open let stackView = UIStackView()
    
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
        stackView.axis = .vertical
        stackView.alignment = .top
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: LayoutConstants.verticalMargin),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    // MARK: - Config
    
    open func setRows(_ viewModels: [TasksListInformationRowViewModel]?) {
        stackView.removeArrangedSubviewsFromViewHierarchy()
        
        guard let viewModels = viewModels, viewModels.count > 0 else {
            return
        }
        
        // Add first (max) view models
        for viewModel in viewModels[0..<min(maxViews, viewModels.count)] {
            let infoRow = TasksListInfoRowView()
            infoRow.decorate(with: viewModel)
            stackView.addArrangedSubview(infoRow)
        }
        
        // Add spacer view if less than max views
        if stackView.arrangedSubviews.count < maxViews + 1 {
            stackView.addArrangedSubview(UIView())
        }
    }
}
