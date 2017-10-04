//
//  CallsignStatusViewModel.swift
//  ClientKit
//
//  Created by Kyle May on 3/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CallsignStatusViewModel {
    
    public enum CallsignState: CustomStringConvertible {
        case unassigned
        case assigned(callsign: String, status: String)
        
        public var description: String {
            switch self {
            case .unassigned:
                return "Not booked on"
            case .assigned(let callsign, _):
                return callsign
            }
        }
        
        public var actionText: String {
            switch self {
            case .unassigned:
                return "View all callsigns"
            case .assigned(_, let status):
                return status
            }
        }
        
        public var icon: UIImage? {
            // TODO: Get real image
            return AssetManager.shared.image(forKey: .entityCar)
        }
    }
    
    public var state: CallsignState = .unassigned {
        didSet {
            // TODO: Post a notification or something?
        }
    }
    
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
