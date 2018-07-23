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
    public let stackView = UIStackView()
    private var infoRowViews: [TasksListInfoRowView] = []
    
    // MARK: - Properties
    
    /// Maximum number of views to show in the stack view
    private var maxViews: Int

    // MARK: - Setup
    
    public init(frame: CGRect = .zero, maxViews: Int = 0) {
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
        guard let viewModels = viewModels else {
            infoRowViews.forEach { $0.decorate(with: .blank) }
            return
        }
        
        // Only allow the max views
        let allowedVmCount = min(maxViews, viewModels.count)
        
        if viewModels.count > infoRowViews.count {
            // Have more views models than current views, need to add more
            for _ in infoRowViews.count..<allowedVmCount {
                let infoRow = TasksListInfoRowView()
                stackView.addArrangedSubview(infoRow)
                infoRowViews.append(infoRow)
            }
        } else if viewModels.count < infoRowViews.count {
            // Has less view models than current views, need to hide some
            for i in allowedVmCount..<infoRowViews.count {
                infoRowViews[i].decorate(with: .blank)
            }
        }
        
        for (index, viewModel) in viewModels[0..<viewModels.count].enumerated() {
            let infoRow = infoRowViews[index]
            infoRow.decorate(with: viewModel)
        }
        
        // Add spacer view if less than max views
        if stackView.arrangedSubviews.count < maxViews {
            let infoRow = TasksListInfoRowView()
            infoRow.decorate(with: .blank)
            stackView.addArrangedSubview(infoRow)
            infoRowViews.append(infoRow)
        }
    }
}
