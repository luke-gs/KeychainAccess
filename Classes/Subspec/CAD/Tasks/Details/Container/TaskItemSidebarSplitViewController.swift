//
//  TaskItemSidebarSplitViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class TaskItemSidebarSplitViewController: SidebarSplitViewController {

    private let headerView = SidebarHeaderView(frame: .zero)
    private let detailViewModel: TaskItemViewModel
    private var compactStatusChangeBar: GlassBarView?
    private let pencilCircleView = UIImageView()
    private let refreshControl = UIRefreshControl()

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
        regularSidebarViewController.sidebarTableView?.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        // Add pencil icon
        let circleImage = AssetManager.shared.image(forKey: .edit)?
            .withCircleBackground(tintColor: .primaryGray,
                                  circleColor: .white,
                                  style: .fixed(size: CGSize(width: 32, height: 32),
                                                padding: CGSize(width: 20, height: 20)),
                                  shouldCenterImage: true)
        
        pencilCircleView.layer.shadowRadius = 4
        pencilCircleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        pencilCircleView.layer.shadowColor = UIColor.black.cgColor
        pencilCircleView.layer.shadowOpacity = 0.5
        pencilCircleView.image = circleImage
        pencilCircleView.isUserInteractionEnabled = false
        pencilCircleView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(pencilCircleView)
        
        NSLayoutConstraint.activate([
            pencilCircleView.topAnchor.constraint(equalTo: headerView.iconView.topAnchor, constant: -8),
            pencilCircleView.trailingAnchor.constraint(equalTo: headerView.iconView.trailingAnchor, constant: 8),
            pencilCircleView.heightAnchor.constraint(equalToConstant: 32),
            pencilCircleView.widthAnchor.constraint(equalTo: pencilCircleView.heightAnchor),
        ])

        NotificationCenter.default.addObserver(self, selector: #selector(callsignChanged), name: .CADCallsignChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(callsignChanged), name: .CADBookOnChanged, object: nil)
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
        updateHeaderView()
        configureCompactChangeStatusBar()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateHeaderView()
        configureCompactChangeStatusBar()
    }

    open override func masterNavTitleSuitable(for traitCollection: UITraitCollection) -> String {
        // Ask the data source for an appropriate title
        if traitCollection.horizontalSizeClass == .compact {
            return detailViewModel.compactNavTitle ?? ""
        } else {
            return detailViewModel.navTitle ?? ""
        }
    }

    open override func masterNavSubtitleSuitable(for traitCollection: UITraitCollection) -> String? {
        if let intervalString = CADStateManager.shared.lastSyncTime?.elapsedTimeIntervalForHuman() {
            return "Updated \(intervalString)"
        }
        return nil
    }

    /// Updates the header view with the details for the latest selected representation.
    /// Call this method when the selected representation changes.
    private func updateHeaderView() {
        headerView.iconView.tintColor = detailViewModel.iconTintColor
        headerView.iconView.image = detailViewModel.iconImage
        headerView.iconView.contentMode = .center
        headerView.captionLabel.text = detailViewModel.statusText?.localizedUppercase
        headerView.titleLabel.text = detailViewModel.itemName
        headerView.subtitleLabel.text = detailViewModel.subtitleText

        if let color = detailViewModel.color {
            headerView.iconView.backgroundColor = color
            headerView.captionLabel.textColor = color
        }
        
        // Hide pencil icon if is compact or view model doesn't allow status changes
        pencilCircleView.isHidden = isCompact() || !detailViewModel.allowChangeResourceStatus()
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
        
        if detailViewModel.allowChangeResourceStatus() == true {
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

        // Dismiss change state dialog if we no longer have an incident
        if let modal = presentedViewController, CADStateManager.shared.currentIncident == nil {
            modal.dismiss(animated: true, completion: nil)
        }
    }

    @objc open func didTapStatusChangeButton() {
        detailViewModel.didTapTaskStatus()
    }
    
    @objc open func refreshData() {
        detailViewModel.refreshTask().always {
            self.refreshControl.endRefreshing()
        }.catch { error in
            AlertQueue.shared.addErrorAlert(message: error.localizedDescription)
        }
    }
}

