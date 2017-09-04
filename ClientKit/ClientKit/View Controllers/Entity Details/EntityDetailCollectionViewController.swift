//
//  EntityDetailCollectionViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

// TODO: This needs a refactor... should become a protocol but we need the typesafety
//       to ensure it's a UIViewController. For now, it's ok... but this really isn't needed.
//       Swift 4 will allow EntityDetailVC & UIViewController and the world will be sane again.

/// An abstract view controller for presenting entity details.
open class EntityDetailCollectionViewController: FormCollectionViewController, EntityDetailSectionUpdatable {
    // MARK: Public properties

    /// The current entity to be presented.
    ///
    /// Subclasses should override this property to handle updating their
    /// content.
    open var entity: Entity?

    public var genericEntity: MPOLKitEntity? {
        get {
            return entity
        }

        set {
            entity = genericEntity as? Entity
        }
    }

}
