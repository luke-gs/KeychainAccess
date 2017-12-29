//
//  EventDetailsViewModelRouter.swift
//  ClientKit
//
//  Created by RUI WANG on 25/7/17.
//  Copyright © 2017 Rod Brown. All rights reserved.
//

import Foundation

class EventDetailsViewModelRouter {
    
    typealias RegEntry = (
        eventClass: Event.Type,
        viewModelClass: EventDetailsViewModel.Type
    )
    
    static var registry = [String: RegEntry]()
    
    static func register<E: Event, V: EventDetailsViewModel>(eventClass: E.Type, viewModelClass: V.Type?) {
        
        let key = String(describing: eventClass)
        
        if let viewModelClass = viewModelClass {
            registry[key] = (eventClass, viewModelClass)
        } else {
            registry.removeValue(forKey: key)
        }
    }
    
    static func getViewModel<T: Event>(for event: T) -> EventDetailsViewModel? {
        
        let target = registry[String(describing: type(of: event))]
        
        guard let (_, viewModelClass) = target else { return nil }
        
        return viewModelClass.init(event: event)
    }
}
