//
//  CollectionViewFormEditAction.swift
//  MPOLKit
//
//  Created by Rod Brown on 23/08/2016.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A structure representing a collection view edit action.
///
/// `CollectionViewFormEditAction`s are not equatable because its semantics
/// do not match those required by the `Equatable` protocol. Specifically,
/// we cannot compare the handlers, and therefore cannot check
/// whether the two structs are functionally equivalent (i.e. "substitutable")
/// as required by the protocol definition.
///
/// You should use the `isVisuallyEqual(to:)` method to determine whether
/// two actions have the same visual attributes.
public struct CollectionViewFormEditAction {
    
    public var title:  String
    public var color:  UIColor?
    public var handler: ((CollectionViewFormCell, IndexPath) -> Void)?
    
    public init(title: String, color: UIColor?, handler: ((CollectionViewFormCell, IndexPath) -> Void)?) {
        self.title   = title
        self.color   = color
        self.handler = handler
    }
    
    
    /// Determines if the action is visually identical to another edit action.
    ///
    /// - Parameter action: The compared action.
    /// - Returns: `true` if the two items are visually identical. Otherwise, `false`.
    public func isVisuallyEqual(to action: CollectionViewFormEditAction) -> Bool {
        return title == action.title && color == action.color
    }
    
}
