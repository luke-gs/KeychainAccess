//
//  ActionListViewController.swift
//  MPOL
//
//  Created by Rod Brown on 29/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class ActionListViewController: FormCollectionViewController {
    
    override init() {
        super.init()
        title = NSLocalizedString("Action List", comment: "Title")
        
        tabBarItem.image = AssetManager.shared.image(forKey: .tabBarActionList)
        tabBarItem.isEnabled = false
    }
    
}
