//
//  TimelineFormCollectionViewController.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Custom form collection view that overrides the form layout class
open class TimelineFormCollectionViewController<ItemType>: CADFormCollectionViewController<ItemType> {
    open override func collectionViewLayoutClass() -> CollectionViewFormLayout.Type {
        return TimelineCollectionViewFormLayout.self
    }
}

