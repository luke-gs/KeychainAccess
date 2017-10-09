//
//  TaskItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public struct TaskItemViewModel {
    
    /// Icon image to display in the header
    var iconImage: UIImage?

    /// Status text to display below the icon (e.g. 'In Duress')
    var statusText: String?
    
    /// Name of the item (e.g. 'P08')
    var itemName: String?
    
    /// Last updated time string (e.g. '2 mins ago')
    var lastUpdated: String?
    
    /// Color to use for the icon image background and status text
    var color: UIColor?
    
    /// View controllers to show in the list
    var detailViewControllers: [UIViewController]?
}
