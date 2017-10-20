//
//  BookOnStatusViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 3/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// View model for the Book-on status view in the tab bar
open class BookOnStatusViewModel {
    
    open weak var delegate: BookOnStatusViewModelDelegate?
    
    // MARK: - State
    
    /// Enum to keep track of un/assigned book-on state
    public enum BookOnState {
        /// Not assigned to any callsign
        /// - `title`: Title to show when not booked on
        /// - `subtitle`: Description to show when not booked on
        case unassigned(title: String, subtitle: String)
        
        /// Assigned to a callsign
        /// - `callsign`: The callsign identifier
        /// - `status`: Status of callsign tasking (e.g. On Air, At Incident)
        /// - `image`: The image to show next to the callsign identifier
        case assigned(callsign: String, status: String, image: UIImage?)
        
        /// Title text to show
        public var title: String {
            switch self {
            case .unassigned(let title, _):
                return title
            case .assigned(let callsign, _, _):
                return callsign
            }
        }
        
        /// Subtitle text to show which details the action that will be performed
        /// when clicking on the status view
        public var actionText: String {
            switch self {
            case .unassigned(_, let subtitle):
                return subtitle
            case .assigned(_, let status, _):
                return status
            }
        }
        
        /// Image to be shown next to the text representing the callsign
        public var icon: UIImage? {
            if case let .assigned(_, _, image) = self {
                return image
            }
            
            return nil
        }
    }
    
    /// The currently selected state
    open var state: BookOnState = BookOnStatusViewModel.defaultNotBookedOnState {
        // TODO: Get this from user session and keep updated
        didSet {
            delegate?.viewModelStateChanged()
        }
    }
    
    /// Default text for not booked on state
    open static let defaultNotBookedOnState: BookOnState = {
        return .unassigned(title: NSLocalizedString("Not Booked On", comment: ""),
                           subtitle: NSLocalizedString("View All Callsigns", comment: "")
        )
    }()

    // MARK: - Computed
    
    open var titleText: String {
        return state.title
    }
    
    open var subtitleText: String {
        return state.actionText
    }
    
    open var iconImage: UIImage? {
        return state.icon
    }
    
    // MARK: - Setup
    
    public init() {}
    
    /// Creates the view for this view model
    open func createView() -> BookOnStatusView {
        return BookOnStatusView(viewModel: self)
    }
    
    /// Creates the view controller to present for tapping the button
    open func createActionViewController() -> UIViewController? {
        switch state {
        case .unassigned(_, _):
            return NotBookedOnViewModel().createViewController()
        case .assigned(_, _, _):
            return nil
        }
    }
}

/// Delegate for the book-on status view model
public protocol BookOnStatusViewModelDelegate: class {
    /// Called when the callsign state changes
    func viewModelStateChanged()
}
