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

    init(_ status: ResourceStatus) {
        self.title = status.title
        self.image = status.icon!
        self.status = status
    }
}

/// Protocol for UI backing view model
public protocol ManageCallsignStatusViewModelDelegate: PopoverPresenter, NavigationPresenter {
    func callsignDidChange()
}

/// View model for the callsign status screen
open class ManageCallsignStatusViewModel {

    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(notifyDataChanged), name: .CADCallsignChanged, object: nil)
    }

    /// Concrete view model used to present book on details form
    struct BookOnCallsignViewModel: BookOnCallsignViewModelType {
        var callsign: String
        var status: String?
        var location: String?
        var type: ResourceType?
    }

    /// Enum for action button types
    enum ActionButton: Int {
        case viewCallsign
        case manageCallsign
        case terminateShift

        var title: String {
            switch self {
            case .viewCallsign:
                return NSLocalizedString("View My Call Sign", comment: "View call sign button text")
            case .manageCallsign:
                return NSLocalizedString("Manage Call Sign", comment: "Manage call sign button text")
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
        return CallsignStatusViewModel(sections: callsignSectionsForState(), selectedStatus: callsignStatus, incident: nil)
    }()

    public var incidentListViewModel: TasksListIncidentViewModel? {
        if let incident = CADStateManager.shared.currentIncident {
            return TasksListIncidentViewModel(incident: incident, showsDescription: false, showsResources: false, hasUpdates: false)
        }
        return nil
    }

    public var incidentTaskViewModel: IncidentTaskItemViewModel? {
        if let incident = CADStateManager.shared.currentIncident, let resource = CADStateManager.shared.currentResource {
            return IncidentTaskItemViewModel(incident: incident, resource: resource)
        }
        return nil
    }

    @objc private func notifyDataChanged() {
        delegate?.callsignDidChange()
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
        if let lastBookOn = CADStateManager.shared.lastBookOn {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let shiftStart = formatter.string(from: lastBookOn.shiftStart!)
            let shiftEnd = formatter.string(from: lastBookOn.shiftEnd!)
            return "\(shiftStart) - \(shiftEnd)"
        }
        return ""
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
                        status: CADStateManager.shared.currentResource?.status.title ?? "",
                        location: CADStateManager.shared.currentResource?.station ?? "",
                        type: CADStateManager.shared.currentResource?.type)
                    delegate?.present(BookOnScreen.bookOnDetailsForm(callsignViewModel: callsignViewModel))
                }
                break
            case .terminateShift:
                if callsignViewModel.currentStatus?.canTerminate == true {
                    // Update session and dismiss screen
                    CADStateManager.shared.setOffDuty()
                    delegate?.dismiss(animated: true, completion: nil)
                } else {
                    AlertQueue.shared.addSimpleAlert(title: NSLocalizedString("Unable to Terminate Shift", comment: ""),
                                                     message: NSLocalizedString("Your call sign is currently responding to an active incident that must first be finalised.", comment: ""))
                }
                break
            }
        }
    }
    
    // MARK: - Data

    open func callsignSectionsForState() -> [CADFormCollectionSectionViewModel<ManageCallsignStatusItemViewModel>] {
        var sections: [CADFormCollectionSectionViewModel<ManageCallsignStatusItemViewModel>] = []
        if shouldShowIncident {
            sections.append(CADFormCollectionSectionViewModel(
                title: NSLocalizedString("Incident Status", comment: "Incident Status header text"),
                items: [
                    ManageCallsignStatusItemViewModel(.proceeding),
                    ManageCallsignStatusItemViewModel(.atIncident),
                    ManageCallsignStatusItemViewModel(.finalise),
                    ManageCallsignStatusItemViewModel(.inquiries2) ]))

        }
        sections.append(CADFormCollectionSectionViewModel(
            title: NSLocalizedString("General", comment: "General status header text"),
            items: [
                ManageCallsignStatusItemViewModel(.unavailable),
                ManageCallsignStatusItemViewModel(.onAir),
                ManageCallsignStatusItemViewModel(.mealBreak),
                ManageCallsignStatusItemViewModel(.trafficStop),
                ManageCallsignStatusItemViewModel(.court),
                ManageCallsignStatusItemViewModel(.atStation),
                ManageCallsignStatusItemViewModel(.onCall),
                ManageCallsignStatusItemViewModel(.inquiries1) ]))
        
        return sections
    }
}
