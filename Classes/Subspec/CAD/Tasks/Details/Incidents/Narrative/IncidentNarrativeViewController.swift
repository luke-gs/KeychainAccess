    //
//  IncidentNarrativeViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class IncidentNarrativeViewController: ActivityLogViewController {

    public init(viewModel: IncidentNarrativeViewModel) {
        super.init(viewModel: viewModel)
        
        sidebarItem.image = AssetManager.shared.image(forKey: .list)

        if viewModel.allowCreate() {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonTapped))
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
}
