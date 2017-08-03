//
//  SearchTypeDataSource.swift
//  MPOL
//
//  Created by Rod Brown on 13/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A searchable object. 
/// The datasource should know the options and types and what to do with them
public struct Searchable: Equatable {

    /// The search text
    public var searchText: String?

    /// The filter options. 
    /// - Key: the index of the filter
    /// - Value: the value of the filter
    public var options: [Int: String]?

    /// The type of search
    public var type: String?
}

public func ==(lhs: Searchable, rhs: Searchable) -> Bool {
    return lhs.searchText == rhs.searchText
        && lhs.type == rhs.type
}

public protocol SearchOptions {

    /// The number of filters for this data source
    var numberOfOptions: Int { get }

    /// The title for the filter.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The title for the filter.
    func title(at index: Int) -> String

    /// The value specified for the filter, if any.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The value for the filter, if any.
    ///                    Returns `nil` when there is no specific value for the filter.
    func value(at index: Int) -> String?

    /// The default value for the filter when there is no specific value.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The default value for the filter.
    func defaultValue(at index: Int) -> String
}

public protocol SearchDataSource {

    /// The entities retrived from the request
    /// - note: override the getters and setters to return your type of Entity
    var entities: [MPOLKitEntity]? { get }

    /// The sorted entities
    /// - note: override the getter with your custom sorting logic
    var sortedEntities: [MPOLKitEntity]? { get }

    /// The filtered entities used in the "Alerts" part of the search VC
    /// - note: override the getter with your custom filtering logic
    var filteredEntities: [MPOLKitEntity]? { get }

    /// The filter object used to declare all filtering rules
    var options: SearchOptions { get }

    /// The localized Display name for the
    var localizedDisplayName: String { get }

    /// The badge title
    var localizedSourceBadgeTitle: String { get }

    /// The updating delegate. This lets the search view controllers know when you've updated any of the filters
    weak var updatingDelegate: SearchDataSourceUpdating? { get set }

    /// The keyboard type for the search text
    static var keyboardType: UIKeyboardType { get }

    /// The auto-capitilization type for te search text
    static var autoCapitalizationType: UITextAutocapitalizationType { get }

    /// The update controller for updating the values in this filter.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The view controller for updating this value.
    ///                    When a standard `UIViewController` is returned, it is expected it will be contained
    ///                    in a `UINavigationController`.
    func updateController(forFilterAt index: Int) -> UIViewController?

    /// You should create a request with the parameters provided and start
    ///
    /// - Parameters:
    ///   - searchable: the searchable object with the query information
    ///   - completion: the completion block `success`: if the datasource updated successfully with new data, `error`: the error
    /// - Throws: some error
    func searchOperation(searchable: Searchable, completion: ((_ success: Bool, _ error: Error?)->())?) throws

    /// Decorate the generic cell
    ///
    /// - Parameters:
    ///   - cell: the cell to decorate
    ///   - indexPath: the indexPath of the cell, (most likely correlating to the index of the entity to decorate with)
    ///   - style: the style of the cell
    func decorate(cell: EntityCollectionViewCell, at indexPath: IndexPath, style: EntityCollectionViewCell.Style)

    /// Decorate the alert section cells
    ///
    /// - Parameters:
    ///   - cell: the cell to decorate
    ///   - indexPath: the indexPath of the cell, (most likely correlating to the index of the entity to decorate with)
    ///   - style: the style of the cell
    func decorateAlert(cell: EntityCollectionViewCell, at indexPath: IndexPath, style: EntityCollectionViewCell.Style)

    /// Decorate the cells when the collection view is in list view mode
    ///
    /// - Parameters:
    ///   - cell: the cell to decorate
    ///   - indexPath: the indexPath of the cell, (most likely correlating to the index of the entity to decorate with)
    func decorateList(cell: EntityListCollectionViewCell, at indexPath: IndexPath)
}

public protocol SearchDataSourceUpdating: class {
    func searchDataSourceRequestDidChange(_ dataSource: SearchDataSource)
    func searchDataSource(_ dataSource: SearchDataSource, didUpdateFilterAt index: Int)
}
