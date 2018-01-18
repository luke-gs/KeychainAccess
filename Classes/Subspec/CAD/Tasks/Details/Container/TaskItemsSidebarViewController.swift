//
//  TasksItemSidebarViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class TasksItemSidebarViewController: SidebarSplitViewController {

    private let headerView = SidebarHeaderView(frame: .zero)
    private let detailViewModel: TaskItemViewModel
    private var compactStatusChangeBar: GlassBarView?
    
    public init(viewModel: TaskItemViewModel) {
        
        detailViewModel = viewModel
        
        super.init(detailViewControllers: detailViewModel.detailViewControllers())
        
        title = "Details"
        updateHeaderView()
        
        // Add gesture for tapping icon
        headerView.iconView.isUserInteractionEnabled = true
        headerView.iconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapStatusChangeButton)))

        regularSidebarViewController.title = NSLocalizedString("Details", comment: "")
        regularSidebarViewController.headerView = headerView

        NotificationCenter.default.addObserver(self, selector: #selector(callsignChanged), name: .CADCallsignChanged, object: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        apply(ThemeManager.shared.theme(for: userInterfaceStyle))
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureCompactChangeStatusBar()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        configureCompactChangeStatusBar()
    }

    open override func masterNavTitleSuitable(for traitCollection: UITraitCollection) -> String {
        // Ask the data source for an appropriate title
        if traitCollection.horizontalSizeClass == .compact {
            if let title = detailViewModel.itemName {
                return title
            }
        }
        
        // Use a generic sidebar title
        return NSLocalizedString("Details", comment: "Title for for task details")
    }
    
    /// Updates the header view with the details for the latest selected representation.
    /// Call this methodwhen the selected representation changes.
    private func updateHeaderView() {
        headerView.iconView.tintColor = detailViewModel.iconTintColor
        headerView.iconView.image = detailViewModel.iconImage
        headerView.iconView.contentMode = .center
        headerView.captionLabel.text = detailViewModel.statusText?.localizedUppercase
        headerView.titleLabel.text = detailViewModel.itemName

        if let lastUpdated = detailViewModel.lastUpdated {
            headerView.subtitleLabel.text = lastUpdated
        } else {
            headerView.subtitleLabel.text = nil
        }
        
        if let color = detailViewModel.color {
            headerView.iconView.backgroundColor = color
            headerView.captionLabel.textColor = color
        }
    }

    /// Hides or shows compact change status bar based on trait collection, and configures views
    open func configureCompactChangeStatusBar() {
        guard isCompact() else {
            compactStatusChangeBar?.removeFromSuperview()
            compactStatusChangeBar = nil
            return
        }
        
        if compactStatusChangeBar == nil {
            let compactStatusChangeBar = GlassBarView(blurEffectStyle: .prominent)
            compactStatusChangeBar.translatesAutoresizingMaskIntoConstraints = false
            masterNavController.view.addSubview(compactStatusChangeBar)
            
            NSLayoutConstraint.activate([
                compactStatusChangeBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                compactStatusChangeBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                compactStatusChangeBar.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor),
                compactStatusChangeBar.heightAnchor.constraint(equalToConstant: 72),
            ])
            
            self.compactStatusChangeBar = compactStatusChangeBar
        }
        
        compactStatusChangeBar?.titleLabel.text = detailViewModel.statusText
        // TODO: Add subtitle label
        compactStatusChangeBar?.subtitleLabel.isHidden = true
        compactStatusChangeBar?.imageView.image = detailViewModel.iconImage
        
        if (detailViewModel as? IncidentTaskItemViewModel)?.allowChangeResourceStatus() == true {
            compactStatusChangeBar?.actionImageView.image = AssetManager.shared.image(forKey: .editCell)
            compactStatusChangeBar?.addTarget(self, action: #selector(didTapStatusChangeButton), for: .touchUpInside)
        } else {
            compactStatusChangeBar?.actionImageView.image = nil
            compactStatusChangeBar?.removeTarget(self, action: #selector(didTapStatusChangeButton), for: .touchUpInside)
        }
    }
    
    @objc open func callsignChanged() {
        detailViewModel.reloadFromModel()
        configureCompactChangeStatusBar()
        updateHeaderView()
    }

    @objc open func didTapStatusChangeButton() {
        detailViewModel.didTapTaskStatus()
    }
}

extension TasksItemSidebarViewController: TaskItemViewModelDelegate {
    public func presentStatusSelector(viewController: UIViewController) {
        let size: CGSize
        
        if isCompact() {
            size = CGSize(width: 312, height: 224)
        } else {
            size = CGSize(width: 540, height: 120)
        }
        
        // Add done button
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissAnimated))
        
        self.presentFormSheet(viewController, animated: true, size: size, forced: true)
    }
    
}
