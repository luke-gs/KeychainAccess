//
//  ResourceActivityLogDetailViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class ResourceActivityLogDetailViewController: ActivityLogViewController {

    public override init() {
        super.init()
        title = NSLocalizedString("Activity Log", bundle: .mpolKit, comment: "")
        
        // TODO: Get real item
        sidebarItem.image = AssetManager.shared.image(forKey: .list)
        
        view.backgroundColor = .white
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

}
