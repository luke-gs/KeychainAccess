//
//  EntityAlertsViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

open class EntityAlertsViewController: FormBuilderViewController, EntityDetailSectionUpdatable, FilterViewControllerDelegate {
    
    // MARK: - EntityDetailSectionUpdatable
    
    open var genericEntity: MPOLKitEntity? {
        didSet {
            viewModel.entity = genericEntity as? Entity
        }
    }
    
    // MARK: - Properties
    
    open lazy var viewModel: EntityAlertsViewModel = {
        var vm = EntityAlertsViewModel()
        vm.delegate = self
        return vm
    }()
    
    private let filterBarButtonItem: FilterBarButtonItem

    // MARK: - Setup
    
    public override init() {
        filterBarButtonItem = FilterBarButtonItem(target: nil, action: nil)
        
        super.init()
        
        title = NSLocalizedString("Alerts", bundle: .mpolKit, comment: "")
        sidebarItem.image = AssetManager.shared.image(forKey: .alert)
        updateNoContentDetails(title: viewModel.noContentTitle(), subtitle: viewModel.noContentSubtitle())
        
        filterBarButtonItem.target = self
        filterBarButtonItem.action = #selector(filterItemDidSelect(_:))
        navigationItem.rightBarButtonItem = filterBarButtonItem
    }
    
    open override func construct(builder: FormBuilder) {
        viewModel.construct(builder: builder)
    }
    
    // MARK: - Filtering
    
    @objc private func filterItemDidSelect(_ item: UIBarButtonItem) {
        let filterVC = FilterViewController(options: viewModel.filterOptions())
        filterVC.title = NSLocalizedString("Filter Alerts", comment: "")
        filterVC.delegate = self
        presentPopover(filterVC, barButton: item, animated: true)
    }
    
    public func filterViewControllerDidFinish(_ controller: FilterViewController, applyingChanges: Bool) {
        viewModel.filterViewControllerDidFinish(controller, applyingChanges: applyingChanges)
    }

}

extension EntityAlertsViewController: EntityDetailViewModelDelegate {
    public func updateSidebarItemCount(_ count: UInt) {
        sidebarItem.count = count
    }
    
    public func updateSidebarAlertColor(_ color: UIColor?) {
        sidebarItem.alertColor = color
    }
    
    public func updateLoadingState(_ state: LoadingStateManager.State) {
        loadingManager.state = state
    }
    
    public func reloadData() {
        reloadForm()
    }

    public func updateFilterBarButtonItemActivity() {
        filterBarButtonItem.isActive = viewModel.isFiltered()
    }
    
    public func updateNoContentDetails(title: String?, subtitle: String? = nil) {
        loadingManager.noContentView.titleLabel.text = title
        loadingManager.noContentView.subtitleLabel.text = subtitle
    }
}

