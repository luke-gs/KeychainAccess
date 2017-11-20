//
//  MapFilterViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 17/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public protocol MapFilterViewModel {
    
    var defaultSections: [MapFilterSection] { get }
    var sections: [MapFilterSection] { get set }
    
    /// Resets sections to default
    func reset()
    
    /// Creates the view controller for this view model
    func createViewController() -> UIViewController
    
    /// Text for title
    func titleText() -> String?
    
    /// Text for footer button
    func footerButtonText() -> String?
    
    
}
