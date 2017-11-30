//
//  ManageCallsignStatusViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

/// View model for a single callsign status item
public struct ManageCallsignStatusItemViewModel {
    public let title: String
    public let image: UIImage
}

/// Enum for action button types
private enum ActionButton: Int {
    case viewCallsign
    case manageCallsign
    case terminateShift

    var title: String {
        switch self {
        case .viewCallsign:
            return NSLocalizedString("View My Callsign", comment: "View callsign button text")
        case .manageCallsign:
            return NSLocalizedString("Manage Callsign", comment: "Manage callsign button text")
        case .terminateShift:
            return NSLocalizedString("Terminate Shift", comment: "Terminate shift button text")
        }
    }
}

/// View model for the callsign status screen
open class ManageCallsignStatusViewModel: CADFormCollectionViewModel<ManageCallsignStatusItemViewModel> {

    struct BookOnCallsignViewModel: BookOnCallsignViewModelType {
        var callsign: String
        var status: String?
        var location: String?
    }

    public override init() {
        selectedIndexPath = IndexPath(row: 0, section: 0)
        super.init()
        updateData()
    }

    /// Create the view controller for this view model
    public func createViewController() -> UIViewController {
        let vc = ManageCallsignStatusViewController(viewModel: self)
        self.delegate = vc
        return vc
    }

    public var currentStatus: ResourceStatus {
        return statusForIndexPath(selectedIndexPath)
    }

    /// The current state
    public private(set) var selectedIndexPath: IndexPath {
        didSet {
            // Update session
        }
    }

    /// The action buttons to display below status items
    public var actionButtons: [String] {
        get {
            return [
                ActionButton.viewCallsign.title,
                ActionButton.manageCallsign.title,
                ActionButton.terminateShift.title
            ]
        }
    }

    /// The subtitle to use in the navigation bar
    open func navSubtitle() -> String {
        // TODO: get from user session
        return "10:30 - 18:30"
    }

    /// Attempt to select a new status
    open func setSelectedIndexPath(_ indexPath: IndexPath) -> Promise<ResourceStatus> {
        let newStatus = statusForIndexPath(indexPath)
        if currentStatus.canChangeToStatus(newStatus: newStatus) {

            // TODO: Insert network call here
            return after(seconds: 2.0).then {
                self.selectedIndexPath = indexPath
                return Promise(value: self.currentStatus)
            }
        } else {
            let message = NSLocalizedString("Selection not allowed from this state", comment: "")
            return Promise(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message]))
        }
    }

    /// Method for handling button actions
    open func didTapActionButtonAtIndex(_ index: Int) {
        if let actionButton = ActionButton(rawValue: index) {
            switch actionButton {
            case .viewCallsign:
                break
            case .manageCallsign:
                if let bookOn = CADStateManager.shared.lastBookOn {
                    let callsignViewModel = BookOnCallsignViewModel(
                        callsign: bookOn.callsign,
                        status: CADStateManager.shared.currentIncident?.status ?? "",
                        location: CADStateManager.shared.currentResource?.location.fullAddress ?? "")
                    let vc = BookOnDetailsFormViewModel(callsignViewModel: callsignViewModel).createViewController()
                    delegate?.presentPushedViewController(vc, animated: true)
                }
                break
            case .terminateShift:
                if currentStatus.canTerminate {
                    // Update session and dismiss screen
                    CADStateManager.shared.lastBookOn = nil
                    BookOnDetailsFormViewModel.lastSaved = nil
                    delegate?.dismiss()
                } else {
                    let message = NSLocalizedString("Terminating shift is not allowed from this state", comment: "")
                    AlertQueue.shared.addErrorAlert(message: message)
                }
                break
            }
        }
    }

    // MARK: - Internal

    private func statusForIndexPath(_ indexPath: IndexPath) -> ResourceStatus {
        let index = indexPath.section * numberOfItems(for: 0) + indexPath.row
        return ResourceStatus.allCases[index]
    }

    // MARK: - Override

    /// The title to use in the navigation bar
    open override func navTitle() -> String {
        return CADStateManager.shared.lastBookOn?.callsign ?? ""
    }

    /// Hide arrows
    open override func shouldShowExpandArrow() -> Bool {
        return false
    }

    // MARK: - Data

    private func itemFromStatus(_ status: ResourceStatus) -> ManageCallsignStatusItemViewModel {
        return ManageCallsignStatusItemViewModel(title: status.title, image: status.icon()!)
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
                                                itemFromStatus(.onCall),
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
    }
}
