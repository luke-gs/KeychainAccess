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

    /// The current state
    public var selectedIndexPath: IndexPath? {
        didSet {
            // Update session
        }
    }

    /// The action buttons to display below status items
    public var actionButtons: [String] {
        get {
            return [
                NSLocalizedString("View My Callsign", comment: "View callsign button text"),
                NSLocalizedString("Manage Callsign", comment: "Manage callsign button text"),
                NSLocalizedString("Terminate Shift", comment: "Terminate shift button text")
            ]
        }
    }

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

    private func itemFromStatus(_ status: CallsignStatusMatrix) -> ManageCallsignStatusItemViewModel {
        return ManageCallsignStatusItemViewModel(title: status.title, image: AssetManager.shared.image(forKey: status.imageKey)!)
    }

    open func updateData() {
        sections = [
            CADFormCollectionSectionViewModel(title: NSLocalizedString("General", comment: "General status header text"),
                                              items: [
                                                itemFromStatus(.unavailable),
                                                itemFromStatus(.onAir),
                                                itemFromStatus(.mealBreak),
                                                itemFromStatus(.trafficStop),
                                                itemFromStatus(.court),
                                                itemFromStatus(.atStation),
                                                itemFromStatus(.onCell),
                                                itemFromStatus(.inquiries1)
                ]),

            CADFormCollectionSectionViewModel(title: NSLocalizedString("Current Task", comment: "Current task status header text"),
                                              items: [
                                                itemFromStatus(.proceeding),
                                                itemFromStatus(.atIncident),
                                                itemFromStatus(.finalise),
                                                itemFromStatus(.inquiries2)
                ])
        ]
        selectedIndexPath = IndexPath(row: 0, section: 0)
    }
}
