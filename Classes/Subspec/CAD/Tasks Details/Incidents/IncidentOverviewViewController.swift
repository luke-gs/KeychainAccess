//
//  IncidentOverviewViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class IncidentOverviewViewController: UIViewController {

    var mapViewController: UIViewController!
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = NSLocalizedString("Overview", bundle: .mpolKit, comment: "")
        
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
        view.backgroundColor = .white
        
        let viewModel = TasksMapViewModel()
        
        mapViewController = viewModel.createViewController()
        addChildViewController(mapViewController, toView: view)
        mapViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // TODO: Add form
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mapViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            mapViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapViewController.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 350),
        ])
    }
}
