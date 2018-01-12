//
//  DatedActivityLogContainerViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 12/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class DatedActivityLogContainerViewController: UIViewController {
    
    private var stackView: UIStackView!
    private var contentView: UIView!
    private var scrollView: UIScrollView!
    
    private var viewModel: DatedActivityLogContainerViewModel
    private var viewControllers: [DatedActivityLogViewController]
    
    public init(viewControllers: [DatedActivityLogViewController], viewModel: DatedActivityLogContainerViewModel) {
        self.viewControllers = viewControllers
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func viewDidLoad() {
        edgesForExtendedLayout.remove(.top)
        view.backgroundColor = .white
        title = viewModel.title()
        
        for (index, (viewModel, viewController)) in zip(viewModel.activityLogViewModels, viewControllers).enumerated() {
            viewController.collectionView?.isScrollEnabled = false
            let df = DateFormatter()
            df.dateStyle = .medium
            df.doesRelativeDateFormatting = true
            
            viewController.title = df.string(from: viewModel.date)
            if index != viewControllers.count - 1 {
                viewController.showsBottomDivider = true
            }
        }
        
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentView = UIView()
        contentView.backgroundColor = .orange
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        stackView = UIStackView(arrangedChildViewControllers: viewControllers)
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    
}

public extension UIStackView {
    convenience init(arrangedChildViewControllers: [UIViewController]) {
        let views: [UIView] = arrangedChildViewControllers.map { $0.view }
        
        self.init(arrangedSubviews: views)
    }
}
