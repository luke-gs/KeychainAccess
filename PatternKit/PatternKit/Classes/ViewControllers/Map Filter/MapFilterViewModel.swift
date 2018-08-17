//
//  MapFilterViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 17/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// View model for a `MapFilterViewController`
public protocol MapFilterViewModel {
    
    var defaultSections: [MapFilterSection] { get }
    var sections: [MapFilterSection] { get set }
    
    /// Resets sections to default
    func reset()
    
    /// Text for title
    func titleText() -> String?
    
    /// Text for footer button
    func footerButtonText() -> String?
    
    /// Whether toggling the section off should disable the toggle rows
    func disablesCheckboxesOnSectionDisabled(for section: Int) -> Bool
    
    /// Creates the filter view controller
    func createViewController(delegate: MapFilterViewControllerDelegate?) -> UIViewController
}
