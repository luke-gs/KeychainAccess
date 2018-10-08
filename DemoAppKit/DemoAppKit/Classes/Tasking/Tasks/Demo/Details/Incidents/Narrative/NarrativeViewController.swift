//
//  IncidentNarrativeViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class NarrativeViewController: ActivityLogViewController, TaskDetailsLoadable {

    public init(viewModel: DatedActivityLogViewModel & TaskDetailsViewModel) {
        super.init(viewModel: viewModel)
        
        sidebarItem.image = AssetManager.shared.image(forKey: .list)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
}
