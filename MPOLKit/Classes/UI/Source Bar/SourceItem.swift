//
//  SourceItem.swift
//  Test
//
//  Created by Rod Brown on 13/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// An item representing a source in a source list.
public struct SourceItem {
    
    public enum State {
        case notLoaded
        
        case loading
        
        case loaded(count: UInt, color: UIColor)
        
        case notAvailable
    }
    
    /// The title to show under the item.
    public var title: String?
    
    /// The state for the source item.
    public var state: State
    
    
    /// Initializes a SourceItem.
    public init(title: String, state: State) {
        self.title = title
        self.state = state
    }
    
}


extension SourceItem: Equatable {}

public func ==(lhs: SourceItem, rhs: SourceItem) -> Bool {
    return lhs.state == rhs.state && lhs.title == rhs.title
}


extension SourceItem.State: Equatable {}

public func ==(lhs: SourceItem.State, rhs: SourceItem.State) -> Bool {
    
    switch (lhs, rhs) {
    case let (.loaded(a, b), .loaded(c, d)):
        /// In cases where both are loaded, check the values.
        return a == c && b == d
    case (.notLoaded, .notLoaded), (.loading, .loading), (.notAvailable, .notAvailable):
        /// In non loaded cases, it's true if the values are equal
        return true
    default:
        /// If the above don't match, they're not matches.
        return false
    }
}
