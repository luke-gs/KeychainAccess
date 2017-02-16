//
//  CollectionViewFormEditAction.swift
//  VCom
//
//  Created by Rod Brown on 23/08/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

/// A structure representing a collection view edit action.
public struct CollectionViewFormEditAction {
    
    public var title:  String
    public var color:  UIColor?
    public var action: ((CollectionViewFormCell, IndexPath) -> Void)?
    
    public init(title: String, color: UIColor?, action: ((CollectionViewFormCell, IndexPath) -> Void)?) {
        self.title  = title
        self.color  = color
        self.action = action
    }
}
