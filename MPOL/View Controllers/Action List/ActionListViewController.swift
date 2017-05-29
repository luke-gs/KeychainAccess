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
        
        tabBarItem.image = #imageLiteral(resourceName: "iconOtherAction")
        tabBarItem.selectedImage = #imageLiteral(resourceName: "iconOtherActionFilled")
        tabBarItem.isEnabled = false
    }
    
}
