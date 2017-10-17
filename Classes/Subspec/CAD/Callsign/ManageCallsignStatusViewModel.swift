//
//  ManageCallsignStatusViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// View model for a single callsign status item
public struct ManageCallsignStatusItemViewModel {
    public let title: String
    public let image: UIImage
}

/// View model for the callsign status screen
open class ManageCallsignStatusViewModel: CADFormCollectionViewModel<ManageCallsignStatusItemViewModel> {

    public override init() {
        super.init()
        updateData()
    }

    /// Create the view controller for this view model
    public func createViewController() -> UIViewController {
        return ManageCallsignStatusViewController(viewModel: self)
    }

    /// The subtitle to use in the navigation bar
    open func navSubtitle() -> String {
        // TODO: get from user session
        return "10:30 - 18:30"
    }

    // MARK: - Override

    /// The title to use in the navigation bar
    open override func navTitle() -> String {
        // TODO: get from user session
        return "P24 (2)"
    }

    /// Hide arrows
    open override func shouldShowExpandArrow() -> Bool {
        return false
    }

    // MARK: - Data

    open func updateData() {

    }

    open override func sections() -> [CADFormCollectionSectionViewModel<ManageCallsignStatusItemViewModel>] {
        return [
            CADFormCollectionSectionViewModel(title: NSLocalizedString("General", comment: "General status header text"),
                                              items: [ManageCallsignStatusItemViewModel(title: "Unavailable", image: AssetManager.shared.image(forKey: .sourceBarNone)!)]),
            CADFormCollectionSectionViewModel(title: NSLocalizedString("Current Task", comment: "Current task status header text"),
                                              items: [])
        ]
    }
}
