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
        if let currentStatus = CADStateManager.shared.currentResource?.status {
            selectedIndexPath = indexPathForStatus(currentStatus)
        }
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

    public var shouldShowIncident: Bool {
        return (CADStateManager.shared.currentResource?.currentIncident != nil)
    }

    public var incidentListViewModel: TasksListItemViewModel? {
        if let incident = CADStateManager.shared.currentIncident {
            return TasksListItemViewModel(identifier: incident.identifier,
                                          title: [incident.type, incident.resourceCountString].removeNils().joined(separator: " "),
                                          subtitle: incident.location.fullAddress,
                                          caption: [incident.identifier, incident.secondaryCode].removeNils().joined(separator: " • "),
                                          priority: incident.grade.rawValue,
                                          description: incident.details,
                                          badgeTextColor: incident.grade.badgeColors.text,
                                          badgeFillColor: incident.grade.badgeColors.fill,
                                          badgeBorderColor: incident.grade.badgeColors.border,
                                          hasUpdates: false)
        }
        return nil
    }

    public var incidentTaskViewModel: IncidentTaskItemViewModel? {
        if let incident = CADStateManager.shared.currentIncident, let resource = CADStateManager.shared.currentResource {
            return IncidentTaskItemViewModel(incidentNumber: incident.identifier,
                                             iconImage: resource.status.icon,
                                             iconTintColor: resource.status.iconColors.icon,
                                             color: resource.status.iconColors.background,
                                             statusText: resource.status.title,
                                             itemName: [incident.type, incident.resourceCountString].removeNils().joined(separator: " "),
                                             lastUpdated: resource.lastUpdated.elapsedTimeIntervalForHuman())
        }
        return nil
    }


    /// The subtitle to use in the navigation bar
    open func navSubtitle() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let shiftStart = formatter.string(from: BookOnDetailsFormViewModel.lastSaved!.startTime!)
        let shiftEnd = formatter.string(from: BookOnDetailsFormViewModel.lastSaved!.endTime!)
        return "\(shiftStart) - \(shiftEnd)"
    }

    /// Attempt to select a new status
    open func setSelectedIndexPath(_ indexPath: IndexPath) -> Promise<ResourceStatus> {
        let newStatus = statusForIndexPath(indexPath)
        if currentStatus.canChangeToStatus(newStatus: newStatus) {

            // TODO: Insert network call here
            return after(seconds: 1.0).then {
                self.selectedIndexPath = indexPath
                CADStateManager.shared.updateCallsignStatus(status: newStatus)
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
                        status: CADStateManager.shared.currentResource?.status.rawValue ?? "",
                        location: CADStateManager.shared.currentResource?.station ?? "")
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
        for status in ResourceStatus.allCases {
            if indexPathForStatus(status) == indexPath {
                return status
            }
        }
        return .unavailable
    }

    private func indexPathForStatus(_ status: ResourceStatus) -> IndexPath {
        switch status {
        case .unavailable:
            return IndexPath(row: 0, section: 1)
        case .onAir:
            return IndexPath(row: 1, section: 1)
        case .mealBreak:
            return IndexPath(row: 2, section: 1)
        case .trafficStop:
            return IndexPath(row: 3, section: 1)
        case .court:
            return IndexPath(row: 4, section: 1)
        case .atStation:
            return IndexPath(row: 5, section: 1)
        case .onCall:
            return IndexPath(row: 6, section: 1)
        case .inquiries1:
            return IndexPath(row: 7, section: 1)
        case .proceeding:
            return IndexPath(row: 0, section: 0)
        case .atIncident:
            return IndexPath(row: 1, section: 0)
        case .finalise:
            return IndexPath(row: 2, section: 0)
        case .inquiries2:
            return IndexPath(row: 3, section: 0)
        }
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
        return ManageCallsignStatusItemViewModel(title: status.title, image: status.icon!)
    }

    open func updateData() {
        var data: [CADFormCollectionSectionViewModel<ManageCallsignStatusItemViewModel>] = []
        if shouldShowIncident {
            data.append(CADFormCollectionSectionViewModel(title: NSLocalizedString("Incident Status", comment: "Incident Status header text"),
                                                          items: [
                                                            itemFromStatus(.proceeding),
                                                            itemFromStatus(.atIncident),
                                                            itemFromStatus(.finalise),
                                                            itemFromStatus(.inquiries2) ]))

        }
        data.append(CADFormCollectionSectionViewModel(title: NSLocalizedString("General", comment: "General status header text"),
                                                      items: [
                                                        itemFromStatus(.unavailable),
                                                        itemFromStatus(.onAir),
                                                        itemFromStatus(.mealBreak),
                                                        itemFromStatus(.trafficStop),
                                                        itemFromStatus(.court),
                                                        itemFromStatus(.atStation),
                                                        itemFromStatus(.onCall),
                                                        itemFromStatus(.inquiries1) ]))
        sections = data
    }
}
