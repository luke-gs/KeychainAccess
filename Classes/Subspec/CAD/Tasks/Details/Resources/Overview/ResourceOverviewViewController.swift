//
//  ResourceOverviewViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 5/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit

open class ResourceOverviewViewController: UIViewController {
    
    open var mapViewController: TasksMapViewController!
    open var formViewController: FormBuilderViewController!
    open var scrollView: UIScrollView!
    
    open let viewModel: ResourceOverviewViewModel
    
    public init(viewModel: ResourceOverviewViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        title = viewModel.navTitle()
        sidebarItem.image = AssetManager.shared.image(forKey: .info)

        if viewModel.showManageButton() {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Manage", comment: ""), style: .done, target: self, action: #selector(manageButtonTapped))
        }
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
        
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let mapViewModel = ResourceOverviewMapViewModel(callsign: viewModel.callsign)
        mapViewController = mapViewModel.createViewController()
        addChildViewController(mapViewController, toView: scrollView)
        mapViewController.showsMapButtons = false
        mapViewController.mapView.isZoomEnabled = false
        mapViewController.mapView.isPitchEnabled = false
        mapViewController.mapView.isRotateEnabled = false
        mapViewController.mapView.isScrollEnabled = false
        mapViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        formViewController = viewModel.createFormViewController()
        addChildViewController(formViewController, toView: scrollView)
        formViewController.view.translatesAutoresizingMaskIntoConstraints = false
        formViewController.collectionView?.isScrollEnabled = false

    }
    
    /// Activates view constraints
    private func setupConstraints() {
        guard let collectionView = formViewController.collectionView else { return }
        
        // Change collection view to not use autoresizing mask constraints so it uses intrinsic content height
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            mapViewController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            mapViewController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mapViewController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            mapViewController.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 280),
            mapViewController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            
            collectionView.topAnchor.constraint(equalTo: formViewController.view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: formViewController.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: formViewController.view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: formViewController.view.bottomAnchor),
            
            formViewController.view.topAnchor.constraint(equalTo: mapViewController.view.bottomAnchor),
            formViewController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            formViewController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            formViewController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            formViewController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }

    @objc func manageButtonTapped () {
        viewModel.manageCallsign()
    }

}

// MARK: - CADFormCollectionViewModelDelegate
extension ResourceOverviewViewController: CADFormCollectionViewModelDelegate {

    public func sectionsUpdated() {
        // Reload content
        formViewController.reloadForm()
    }
}
