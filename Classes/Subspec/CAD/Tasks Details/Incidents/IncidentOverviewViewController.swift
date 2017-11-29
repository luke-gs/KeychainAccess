//
//  IncidentOverviewViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class IncidentOverviewViewController: UIViewController {

    open var mapViewController: UIViewController!
    open var formViewController: FormBuilderViewController!
    
    open let viewModel: IncidentOverviewViewModel
    
    public init(viewModel: IncidentOverviewViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    
        title = viewModel.navTitle()
        sidebarItem.image = AssetManager.shared.image(forKey: .info)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
    }
    
    /// Creates and styles views
    private func setupViews() {
        edgesForExtendedLayout = []
        
        view.backgroundColor = .white
        
        let mapViewModel = TasksMapViewModel()
        mapViewController = mapViewModel.createViewController()
        addChildViewController(mapViewController, toView: view)
        mapViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        formViewController = viewModel.createFormViewController()
        addChildViewController(formViewController, toView: view)
        // Change collection view to not use autoresizing mask constraints so it uses intrinsic content height
        if let collectionView = formViewController.collectionView {
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: formViewController.view.topAnchor),
                collectionView.leadingAnchor.constraint(equalTo: formViewController.view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: formViewController.view.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: formViewController.view.bottomAnchor),
            ])
        }
        formViewController.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mapViewController.view.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
            mapViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapViewController.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 280),

            formViewController.view.topAnchor.constraint(equalTo: mapViewController.view.bottomAnchor),
            formViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            formViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            formViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
    }
}
