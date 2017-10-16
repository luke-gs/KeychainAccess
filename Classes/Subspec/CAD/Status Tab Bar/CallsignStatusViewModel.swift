//
//  CallsignStatusViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 3/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CallsignStatusViewModel {
    
    public enum CallsignState: CustomStringConvertible {
        case unassigned(subtitle: String)
        case assigned(callsign: String, status: String, image: UIImage?)
        
        public var description: String {
            switch self {
            case .unassigned:
                return "Not booked on"
            case .assigned(let callsign, _, _):
                return callsign
            }
        }
        
        public var actionText: String {
            switch self {
            case .unassigned(let subtitle):
                return subtitle
            case .assigned(_, let status, _):
                return status
            }
        }
        
        public var icon: UIImage? {
            if case let .assigned(_, _, image) = self {
                return image
            }
            
            return nil
        }
    }
    
    public var state: CallsignState = .unassigned(subtitle: "View all callsigns") {
        didSet {
            // TODO: Post a notification or something?
        }
    }

    public init() {}
    
    var titleText: String {
        return state.description
    }
    
    var subtitleText: String {
        return state.actionText
    }
    
    var iconImage: UIImage? {
        return state.icon
    }
}
