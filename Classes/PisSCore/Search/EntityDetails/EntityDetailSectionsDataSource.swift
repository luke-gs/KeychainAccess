//
//  EntityDetailSectionsDataSource.swift
//  ClientKit
//
//  Created by RUI WANG on 21/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// Defines an object that has an Entity and LoadingStateManager so it could be notified about the update status
/// of the new data.
public protocol EntityDetailSectionUpdatable: class {

    /// The entity
    var genericEntity: MPOLKitEntity? { get set }

    /// The loading manager
    var loadingManager: LoadingStateManager { get }
}

/// Data source defining the entity details
public protocol EntityDetailSectionsDataSource {
    
    typealias EntityDetailViewController = (UIViewController & EntityDetailSectionUpdatable)

    /// The source of the data
    var source: EntitySource { get }

    /// The entity associated with the data source
    var entity: MPOLKitEntity { get }

    /// The localised display name
    var localizedDisplayName: String { get }

    /// An array of view controllers that are shown as sections in the sidebar of the entity details screen
    var detailViewControllers: [EntityDetailViewController] { get }

    /// Generates a fetchable objects for the initial fetch of data in the entity details screen
    ///
    /// Not used for data matching. Refer to `MatchMaker` for that.
    ///
    /// - Returns: a fetchable oject defining the request that needs to be made to get the details
    func fetchModel() -> Fetchable
}
