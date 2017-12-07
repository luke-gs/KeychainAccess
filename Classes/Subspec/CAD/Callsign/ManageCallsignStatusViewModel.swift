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
    public let status: ResourceStatus
}

/// Protocol for UI backing view model
public protocol ManageCallsignStatusViewModelDelegate: PopoverPresenter, NavigationPresenter {
}

/// View model for the callsign status screen
open class ManageCallsignStatusViewModel {

    /// Concrete view model used to present book on details form
    struct BookOnCallsignViewModel: BookOnCallsignViewModelType {
        var callsign: String
        var status: String?
        var location: String?
    }

    /// Enum for action button types
    enum ActionButton: Int {
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

    /// Delegate for UI
    public weak var delegate: ManageCallsignStatusViewModelDelegate?

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

    /// The callsign view model for changing status
    open lazy var callsignViewModel: CallsignStatusViewModel = {
        let callsignStatus = CADStateManager.shared.currentResource?.status ?? .unavailable
        return CallsignStatusViewModel(sections: callsignSectionsForState(), selectedStatus: callsignStatus)
    }()

    public var incidentListViewModel: TasksListItemViewModel? {
        if let incident = CADStateManager.shared.currentIncident {
            return TasksListItemViewModel(incident: incident, hasUpdates: false)
        }
        return nil
    }

    public var incidentTaskViewModel: IncidentTaskItemViewModel? {
        if let incident = CADStateManager.shared.currentIncident, let resource = CADStateManager.shared.currentResource {
            return IncidentTaskItemViewModel(incident: incident, resource: resource)
        }
        return nil
    }

    /// Create the view controller for this view model
    public func createViewController() -> UIViewController {
        let vc = ManageCallsignStatusViewController(viewModel: self)
        self.delegate = vc
        return vc
    }

    /// The title to use in the navigation bar
    open func navTitle() -> String {
        return CADStateManager.shared.lastBookOn?.callsign ?? ""
    }

    /// The subtitle to use in the navigation bar
    open func navSubtitle() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let shiftStart = formatter.string(from: BookOnDetailsFormViewModel.lastSaved!.startTime!)
        let shiftEnd = formatter.string(from: BookOnDetailsFormViewModel.lastSaved!.endTime!)
        return "\(shiftStart) - \(shiftEnd)"
    }

    /// Method for handling button actions
    open func didTapActionButtonAtIndex(_ index: Int) {
        if let actionButton = ActionButton(rawValue: index) {
            switch actionButton {
            case .viewCallsign:
                if let resource = CADStateManager.shared.currentResource {
                    // Show split view controller for booked on resource
                    let vm = ResourceTaskItemViewModel(resource: resource)
                    let vc = TasksItemSidebarViewController.init(viewModel: vm)
                    delegate?.present(vc, animated: true, completion: nil)
                }
                break
            case .manageCallsign:
                if let bookOn = CADStateManager.shared.lastBookOn {
                    // Edit the book on details
                    let callsignViewModel = BookOnCallsignViewModel(
                        callsign: bookOn.callsign,
                        status: CADStateManager.shared.currentResource?.status.rawValue ?? "",
                        location: CADStateManager.shared.currentResource?.station ?? "")
                    let vc = BookOnDetailsFormViewModel(callsignViewModel: callsignViewModel).createViewController()
                    delegate?.presentPushedViewController(vc, animated: true)
                }
                break
            case .terminateShift:
                if callsignViewModel.currentStatus.canTerminate {
                    // Update session and dismiss screen
                    CADStateManager.shared.lastBookOn = nil
                    BookOnDetailsFormViewModel.lastSaved = nil
                    delegate?.dismiss(animated: true, completion: nil)
                } else {
                    let message = NSLocalizedString("Terminating shift is not allowed from this state", comment: "")
                    AlertQueue.shared.addErrorAlert(message: message)
                }
                break
            }
        }
    }
    
    // MARK: - Data

    private func itemFromStatus(_ status: ResourceStatus) -> ManageCallsignStatusItemViewModel {
        return ManageCallsignStatusItemViewModel(title: status.title, image: status.icon!, status: status)
    }

    open func callsignSectionsForState() -> [CADFormCollectionSectionViewModel<ManageCallsignStatusItemViewModel>] {
        var sections: [CADFormCollectionSectionViewModel<ManageCallsignStatusItemViewModel>] = []
        if shouldShowIncident {
            sections.append(CADFormCollectionSectionViewModel(
                title: NSLocalizedString("Incident Status", comment: "Incident Status header text"),
                items: [
                    itemFromStatus(.proceeding),
                    itemFromStatus(.atIncident),
                    itemFromStatus(.finalise),
                    itemFromStatus(.inquiries2) ]))

        }
        sections.append(CADFormCollectionSectionViewModel(
            title: NSLocalizedString("General", comment: "General status header text"),
            items: [
                itemFromStatus(.unavailable),
                itemFromStatus(.onAir),
                itemFromStatus(.mealBreak),
                itemFromStatus(.trafficStop),
                itemFromStatus(.court),
                itemFromStatus(.atStation),
                itemFromStatus(.onCall),
                itemFromStatus(.inquiries1) ]))
        
        return sections
    }
}
