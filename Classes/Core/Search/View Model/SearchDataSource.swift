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

    /// The filter object used to declare all filtering rules
    var options: SearchOptions { get }

    /// The localized Display name for the
    var localizedDisplayName: String { get }

    /// The search placeholder
    var searchPlaceholder: NSAttributedString? { get }
    
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

    /// Creates a search result view model for the searchable to be used in 
    /// the SearchResultListViewController.
    ///
    /// - Parameters:
    ///   - searchable: the searchable.
    /// - Returns: the search result view model.
    func searchResultModel(for searchable: Searchable) -> SearchResultViewModelable?
}

public protocol SearchDataSourceUpdating: class {
    func searchDataSourceRequestDidChange(_ dataSource: SearchDataSource)
    func searchDataSource(_ dataSource: SearchDataSource, didUpdateFilterAt index: Int)
}
