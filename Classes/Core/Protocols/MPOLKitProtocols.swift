//
//  MPOLKitProtocols.swift
//  Pods
//
//  Created by Pavel Boryseiko on 20/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// The recent searches view controller view model (pretty much just a container)
public protocol SearchRecentsViewModel {

    /// The title of the view cotroller
    var title: String { get }

    /// Array of recently viewed entities
    var recentlyViewed: EntityBucket { get }

    /// Array of recently searched
    var recentlySearched: [Searchable] { get set }

    /// Decorate the recently viewed cell
    ///
    /// - Parameters:
    ///   - cell: the cell to decorate
    ///   - indexPath: the indexPath of the cell (most likely will correlate to the recently viewed entities)
    func decorate(_ cell: EntityCollectionViewCell, at indexPath: IndexPath)

    /// Summary icon to be used in the recently viewed cells
    ///
    /// - Parameter searchable: the searchable object which will most likely contain the type of entity
    /// - Returns: the image to use
    func summaryIcon(for searchable: Searchable) -> UIImage?

}


/// The main search view model container
///
/// Only reason this really exists is that once we pass this in to MPOLKit's main SearchViewController we don't have control over this object's properties
public protocol SearchViewModel {

    /// A delegate back to the search view controller
    var entityDelegate: EntityDetailsDelegate? { get set }

    /// The recent view model
    var recentViewModel: SearchRecentsViewModel { get }

    /// The data sources to be used
    var dataSources: [SearchDataSource] { get }
    
    /// Creates a presentable for entity
    ///
    /// - Parameter entity: The entity
    /// - Returns: The presentable
    func presentable(for entity: MPOLKitEntity) -> Presentable

}
