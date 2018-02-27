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
    public let status: CADResourceStatusType

    public init(_ status: CADResourceStatusType) {
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
        NotificationCenter.default.addObserver(self, selector: #selector(bookonChanged), name: .CADBookOnChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(callsignChanged), name: .CADCallsignChanged, object: nil)
    }

    /// Enum for action button types
    enum ActionButton: Int {
        case viewCallsign
        case manageCallsign

        var title: String {
            switch self {
            case .viewCallsign:
                return NSLocalizedString("View My Call Sign", comment: "View call sign button text")
            case .manageCallsign:
                return NSLocalizedString("Manage Call Sign", comment: "Manage call sign button text")
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
                ActionButton.manageCallsign.title
            ]
        }
    }

    public var shouldShowIncident: Bool {
        return (CADStateManager.shared.currentResource?.currentIncident != nil)
    }

    /// The callsign view model for changing status
    open lazy var callsignViewModel: CallsignStatusViewModel = {
        let callsignStatus = CADStateManager.shared.currentResource?.status ?? CADClientModelTypes.resourceStatus.defaultCase
        return CallsignStatusViewModel(sections: callsignSectionsForState(), selectedStatus: callsignStatus, incident: CADStateManager.shared.currentIncident)
    }()

    public var incidentListViewModel: TasksListIncidentViewModel? {
        if let incident = CADStateManager.shared.currentIncident {
            let source = CADClientModelTypes.taskListSources.incidentCase
            return TasksListIncidentViewModel(incident: incident, source: source, showsDescription: false, showsResources: false, hasUpdates: false)
        }
        return nil
    }

    @objc private func bookonChanged() {
        if CADStateManager.shared.lastBookOn == nil {
            // Close dialog if we have been booked off. In compact mode, this dialog is not presented,
            // but it is cleaned up by CompactCallsignContainerViewController observing book off
            delegate?.dismiss(animated: true, completion: nil)
        }
    }

    @objc private func callsignChanged() {
        let callsignStatus = CADStateManager.shared.currentResource?.status ?? CADClientModelTypes.resourceStatus.defaultCase
        
        callsignViewModel.reload(sections: callsignSectionsForState(), selectedStatus: callsignStatus, incident: CADStateManager.shared.currentIncident)
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
                    let viewModel = ResourceTaskItemViewModel(resource: resource)
                    delegate?.present(TaskItemScreen.landing(viewModel: viewModel))
                }
                break
            case .manageCallsign:
                if let resource = CADStateManager.shared.currentResource {
                    // Edit the book on details
                    delegate?.present(BookOnScreen.bookOnDetailsForm(resource: resource, formSheet: false))
                }
                break
            }
        }
    }
    
    // MARK: - Data

    open func callsignSectionsForState() -> [CADFormCollectionSectionViewModel<ManageCallsignStatusItemViewModel>] {
        var sections: [CADFormCollectionSectionViewModel<ManageCallsignStatusItemViewModel>] = []

        if shouldShowIncident {
            let incidentItems = CADClientModelTypes.resourceStatus.incidentCases.map {
                return ManageCallsignStatusItemViewModel($0)
            }
            sections.append(CADFormCollectionSectionViewModel(title: "", items: incidentItems))

        }
        let generalItems = CADClientModelTypes.resourceStatus.generalCases.map {
            return ManageCallsignStatusItemViewModel($0)
        }
        sections.append(CADFormCollectionSectionViewModel(
            title: NSLocalizedString("General", comment: "General status header text"),
            items: generalItems))
        
        return sections
    }
}
