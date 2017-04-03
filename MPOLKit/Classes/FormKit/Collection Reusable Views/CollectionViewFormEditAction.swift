//
//  CollectionViewFormEditAction.swift
//  MPOLKit/FormKit
//
//  Created by Rod Brown on 23/08/2016.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A structure representing a collection view edit action.
public struct CollectionViewFormEditAction: Equatable {
    
    public var title:  String
    public var color:  UIColor?
    public var handler: ((CollectionViewFormCell, IndexPath) -> Void)?
    
    public init(title: String, color: UIColor?, handler: ((CollectionViewFormCell, IndexPath) -> Void)?) {
        self.title   = title
        self.color   = color
        self.handler = handler
    }
    
}

public func ==(lhs: CollectionViewFormEditAction, rhs: CollectionViewFormEditAction) -> Bool {
    return lhs.title == rhs.title && lhs.color == rhs.color
}
