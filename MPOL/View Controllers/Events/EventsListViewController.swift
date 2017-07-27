//
//  EventsListViewController.swift
//  MPOL
//
//  Created by Rod Brown on 29/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class EventsListViewController: FormCollectionViewController {
    
    override init() {
        super.init()
        title = NSLocalizedString("Involvements", comment: "Title")
        
        tabBarItem.image = AssetManager.shared.image(forKey: .tabBarEvents)
        tabBarItem.isEnabled = false
    }
    
}
