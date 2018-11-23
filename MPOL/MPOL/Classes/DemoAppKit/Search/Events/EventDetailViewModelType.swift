//
//  EventListDisplayable.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
//
import CoreKit

/// The view model definition for the event details for the OOTB product
public protocol EventDetailViewModelType: Evaluatable {

    // The event object
    var event: Event { get }

    /// The title for the details view controller
    var title: String? { get }

    /// The viewcontrollers to be displayed in the detail view for the sections
    var viewControllers: [UIViewController]? { get }

    /// Closure to call when the header gets updated with a new title or subtitle
    var headerUpdated: (() -> Void)? { get set }

    /// The header to display at the top of the sidebar
    ///
    /// `nil` if no header
    ///
    /// The app defines what view to use
    var headerView: UIView? { get }

    /// Initialiser
    ///
    /// - Parameters:
    ///   - event: The event object
    ///   - builder: The screen builder
    init(event: Event, builder: EventScreenBuilding)
}

/// A protocol defining whether the object should be a
/// event header update delegate
public protocol SideBarHeaderUpdateable {
    var delegate: SideBarHeaderUpdateDelegate? { get set }
}

/// The delegate responsible for updating the sidebar header for events
public protocol SideBarHeaderUpdateDelegate: class {
    func updateHeader(with title: String?, subtitle: String?)
}
