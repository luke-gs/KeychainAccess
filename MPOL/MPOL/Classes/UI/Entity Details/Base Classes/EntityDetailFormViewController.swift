//
//  EntityDetailsViewController.swift
//  MPOL
//
//  Created by Megan Efron on 8/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

/// An abstract view controller for presenting entity details. Accepts a subclass of
/// `EntityDetailFormViewModel` which should provide the content.
open class EntityDetailFormViewController: FormBuilderViewController, EntityDetailSectionUpdatable {

    // MARK: Public properties
    
    public var entity: MPOLKitEntity? {
        get {
            return viewModel.entity
        }
        set {
            viewModel.entity = newValue as? Entity
        }
    }
    
    internal let viewModel: EntityDetailFormViewModel
    
    // MARK: - Lifecycle
    
    public init(viewModel: EntityDetailFormViewModel) {
        self.viewModel = viewModel
        super.init()
        
        viewModel.delegate = self
        viewModel.traitCollectionDidChange(traitCollection, previousTraitCollection: nil)
        
        title = viewModel.title
        updateNoContentDetails(title: viewModel.noContentTitle, subtitle: viewModel.noContentSubtitle)
        
        let sidebarItem = self.sidebarItem
        sidebarItem.regularTitle =  viewModel.regularTitle
        sidebarItem.compactTitle =  viewModel.compactTitle
        sidebarItem.image =         viewModel.sidebarImage
        sidebarItem.selectedImage = viewModel.sidebarImage
        
        updateBarButtonItems()
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        viewModel.traitCollectionDidChange(traitCollection, previousTraitCollection: previousTraitCollection)
    }
    
    // MARK: - Form Builder
    
    open override func construct(builder: FormBuilder) {
        viewModel.construct(for: self, with: builder)
    }
}

extension EntityDetailFormViewController: EntityDetailFormViewModelDelegate {
    
    open func updateSidebarItemCount(_ count: UInt?) {
        if let count = count {
            sidebarItem.count = count
        }
    }
    
    open func updateSidebarAlertColor(_ color: UIColor?) {
        sidebarItem.alertColor = color
    }
    
    open func updateLoadingState(_ state: LoadingStateManager.State) {
        loadingManager.state = state
    }
    
    open func reloadData() {
        reloadForm()
    }
    
    open func updateNoContentDetails(title: String?, subtitle: String? = nil) {
        loadingManager.noContentView.titleLabel.text = title
        loadingManager.noContentView.subtitleLabel.text = subtitle
    }
    
    open func updateBarButtonItems() {
        navigationItem.rightBarButtonItems = viewModel.rightBarButtonItems
        navigationItem.leftBarButtonItems = viewModel.leftBarButtonItems
    }
    
}
