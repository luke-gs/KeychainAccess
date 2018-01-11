//
//  EventDetailViewController.swift
//  Pods
//
//  Created by Rod Brown on 26/5/17.
//
//

import UIKit
import MPOLKit

open class EventDetailViewController: FormBuilderViewController {
    
    // MARK: - Poperties
    
    private let viewModel: EventDetailsViewModel
    
    // MARK: - Lifecycle
    
    public init(viewModel: EventDetailsViewModel) {
        self.viewModel = viewModel
        super.init()
        
        viewModel.delegate = self
        
        title = viewModel.title
        loadingManager.loadingLabel.text = viewModel.loadingText
        loadingManager.noContentView.titleLabel.text = viewModel.noContentTitle
        loadingManager.noContentView.subtitleLabel.text = viewModel.noContentSubtitle
        
        viewModel.traitCollectionDidChange(traitCollection, previousTraitCollection: nil)
        viewModel.load()
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func construct(builder: FormBuilder) {
        viewModel.construct(builder: builder)
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        viewModel.traitCollectionDidChange(traitCollection, previousTraitCollection: previousTraitCollection)
    }
}

extension EventDetailViewController: EntityDetailFormViewModelDelegate {
    
    open func reloadData() {
        reloadForm()
    }
    
    open func updateLoadingState(_ state: LoadingStateManager.State) {
        loadingManager.state = state
    }
}
