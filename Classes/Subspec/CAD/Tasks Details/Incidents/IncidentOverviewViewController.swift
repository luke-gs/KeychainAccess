//
//  IncidentOverviewViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit

open class IncidentOverviewViewController: UIViewController {

    open var mapViewController: MapViewController!
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
        
        var region: MKCoordinateRegion?
        
        // Get region from main map view and use as starting point
        if let splitView = pushableSplitViewController?.navigationController?.viewControllers.first as? TasksSplitViewController,
            let mapViewController = splitView.detailVC as? MapViewController
        {
            region = mapViewController.mapView.region
        }
        
        let mapViewModel = IncidentOverviewMapViewModel(incidentNumber: viewModel.incidentNumber)
        mapViewController = mapViewModel.createViewController(startingMapRegion: region)
        addChildViewController(mapViewController, toView: view)
        mapViewController.mapView.isZoomEnabled = false
        mapViewController.mapView.isPitchEnabled = false
        mapViewController.mapView.isRotateEnabled = false
        mapViewController.mapView.isScrollEnabled = false
        mapViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        formViewController = viewModel.createFormViewController()
        addChildViewController(formViewController, toView: view)
        formViewController.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        guard let collectionView = formViewController.collectionView else { return }
        
        // Change collection view to not use autoresizing mask constraints so it uses intrinsic content height
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mapViewController.view.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
            mapViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapViewController.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 280),
            
            collectionView.topAnchor.constraint(equalTo: formViewController.view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: formViewController.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: formViewController.view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: formViewController.view.bottomAnchor),

            formViewController.view.topAnchor.constraint(equalTo: mapViewController.view.bottomAnchor),
            formViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            formViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            formViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
    }
}
