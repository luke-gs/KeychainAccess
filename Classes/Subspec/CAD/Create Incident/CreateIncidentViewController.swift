//
//  CreateIncidentViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 20/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CreateIncidentViewController: ThemedPopoverViewController {

    open let viewModel: CreateIncidentViewModel

    /// Scroll view for content view
    open var scrollView: UIScrollView!
    
    /// Content view for all content
    open var contentView: UIView!

    /// Collection of callsign statuses
    open var callsignStatusVC: CreateIncidentStatusViewController!
    
    /// Form for details
    open var detailsFormVC: IncidentDetailsFormViewController!
    
    override open var wantsTransparentBackground: Bool {
        didSet {
            /// Apply transparent background to child VCs
            callsignStatusVC.wantsTransparentBackground = wantsTransparentBackground
            detailsFormVC.wantsTransparentBackground = wantsTransparentBackground
        }
    }

    public init(viewModel: CreateIncidentViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        setupConstraints()
        setupNavigationBarButtons()
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.navTitle()
    }
    
    /// Creates and styles views
    private func setupViews() {
        scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        callsignStatusVC = viewModel.createStatusViewController()
        callsignStatusVC.collectionView.isScrollEnabled = false
        addChildViewController(callsignStatusVC, toView: contentView)
        
        detailsFormVC = viewModel.createFormViewController()
        detailsFormVC.collectionView?.isScrollEnabled = false
        addChildViewController(detailsFormVC, toView: contentView)
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        let callsignStatusView = callsignStatusVC.view!
        callsignStatusView.translatesAutoresizingMaskIntoConstraints = false
        
        let detailsFormView = detailsFormVC.view!
        detailsFormView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            callsignStatusView.topAnchor.constraint(equalTo: contentView.topAnchor),
            callsignStatusView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            callsignStatusView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            detailsFormView.topAnchor.constraint(equalTo: callsignStatusView.bottomAnchor),
            detailsFormView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            detailsFormView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            detailsFormView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    open func setupNavigationBarButtons() {
        // Create cancel button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissAnimated))
        
        // Create done button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped(_:)))
    }

    @objc private func doneButtonTapped(_ button: UIBarButtonItem) {
        let builder = detailsFormVC.builder
        
        let result = builder.validate()
        
        switch result {
        case .invalid(_, let message):
            builder.validateAndUpdateUI()
            AlertQueue.shared.addErrorAlert(message: message)
        case .valid:
            viewModel.submitForm()
        }
    }
}

extension CreateIncidentViewController: CreateIncidentViewModelDelegate {
    public func contentChanged() {
        self.detailsFormVC.reloadForm()
    }
}
