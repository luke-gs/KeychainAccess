//
//  UserCallsignStatusViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 3/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// View model for the user callsign status view in the tab bar
open class UserCallsignStatusViewModel {
    
    open weak var delegate: UserCallsignStatusViewModelDelegate?
    
    // MARK: - State
    
    /// Enum to keep track of un/assigned callsign state
    public enum CallsignState {
        /// Not assigned to any callsign
        /// - `title`: Title to show when not booked on
        /// - `subtitle`: Description to show when not booked on
        case unassigned(title: String, subtitle: String)
        
        /// Assigned to a callsign
        /// - `callsign`: The callsign identifier
        /// - `officerCount`: The number of officers in callsign
        /// - `status`: Status of callsign tasking (e.g. On Air, At Incident)
        /// - `image`: The image to show next to the callsign identifier
        case assigned(callsign: String, officerCount: String?, status: String, image: UIImage?)
        
        /// Title text to show
        public var title: String {
            switch self {
            case .unassigned(let title, _):
                return title
            case .assigned(let callsign, _, _, _):
                return callsign
            }
        }
        
        /// Subtitle text to show which details the action that will be performed
        /// when clicking on the status view
        public var actionText: String {
            switch self {
            case .unassigned(_, let subtitle):
                return subtitle
            case .assigned(_, _, let status, _):
                return status
            }
        }
        
        /// Officer count to be shown after callsign title
        public var officerCount: String? {
            if case let .assigned(_, officerCount, _, _) = self {
                return officerCount
            } else {
                return nil
            }
        }

        /// Image to be shown next to the text representing the callsign
        public var icon: UIImage? {
            if case let .assigned(_, _, _, image) = self {
                return image
            } else {
                return AssetManager.shared.image(forKey: .iconStatusUnavailable)
            }
        }
    }
    
    /// The currently selected state
    open var state: CallsignState = UserCallsignStatusViewModel.defaultNotBookedOnState {
        didSet {
            delegate?.viewModelStateChanged()
        }
    }
    
    /// Default text for not booked on state
    open static let defaultNotBookedOnState: CallsignState = {
        return .unassigned(title: NSLocalizedString("Not Booked On", comment: ""),
                           subtitle: NSLocalizedString("View All Call Signs", comment: "")
        )
    }()

    // MARK: - Computed
    
    open var titleText: String {
        return [state.title, state.officerCount].joined()
    }
    
    open var subtitleText: String {
        return state.actionText
    }
    
    open var iconImage: UIImage? {
        return state.icon
    }
    
    // MARK: - Setup
    
    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(callsignChanged), name: .CADBookOnChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(callsignChanged), name: .CADCallsignChanged, object: nil)
    }

    @objc open func callsignChanged() {
        if let bookOn = CADStateManager.shared.lastBookOn {
            self.state = .assigned(callsign: bookOn.callsign,
                                   officerCount: CADStateManager.shared.currentResource?.officerCountString,
                                   status: CADStateManager.shared.currentResource?.statusType.title ?? "",
                                   image: CADStateManager.shared.currentResource?.statusType.icon)
        } else {
            self.state = UserCallsignStatusViewModel.defaultNotBookedOnState
        }
    }
    
    /// Creates the view for this view model
    open func createView() -> UserCallsignStatusView {
        let view = UserCallsignStatusView(viewModel: self)
        delegate = view
        return view
    }
    
    /// Creates the view controller to present for tapping the button
    open func screenForAction() -> Presentable {
        switch state {
        case .unassigned(_, _):
            return BookOnScreen.notBookedOn
        case .assigned(_, _, _, _):
            return BookOnScreen.manageBookOn
        }
    }
}

/// Delegate for the user callsign status view model
public protocol UserCallsignStatusViewModelDelegate: class {
    /// Called when the callsign state changes
    func viewModelStateChanged()
}
