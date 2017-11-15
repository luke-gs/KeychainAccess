//
//  TaskItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class TaskItemViewModel {
    
    /// Icon image to display in the header
    var iconImage: UIImage?

    /// Icon image color (not the background!)
    var iconTintColor: UIColor?
    
    /// Color to use for the icon image background and status text
    var color: UIColor?
    
    /// Status text to display below the icon (e.g. 'In Duress')
    var statusText: String?
    
    /// Name of the item (e.g. 'P08')
    var itemName: String?
    
    /// Last updated time string (e.g. '2 mins ago')
    var lastUpdated: String?

    /// View controllers to show in the list
    func detailViewControllers() -> [UIViewController] {
        return viewModels.map {
            $0.createViewController()
        }
    }
    
    public var viewModels: [TaskDetailsViewModel]
    
    /// Init
    ///
    /// - Parameters:
    ///   - iconImage: Icon image to display in the header
    ///   - iconTintColor: Icon image color
    ///   - color: Color to use for the icon image background and status text
    ///   - statusText: Status text to display below the icon
    ///   - itemName: Name of the item
    ///   - lastUpdated: Last updated time string
    public init(iconImage: UIImage?, iconTintColor: UIColor?, color: UIColor, statusText: String?, itemName: String?, lastUpdated: String?, viewModels: [TaskDetailsViewModel] = []) {
        self.iconImage = iconImage
        self.iconTintColor = iconTintColor
        self.color = color
        self.statusText = statusText
        self.itemName = itemName
        self.lastUpdated = lastUpdated
        self.viewModels = viewModels
    }
}
