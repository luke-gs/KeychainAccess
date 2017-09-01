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
public class Searchable: NSObject, NSSecureCoding {

    /// The search text
    public var searchText: String?

    /// The filter options.
    /// - Key: the index of the filter
    /// - Value: the value of the filter
    public var options: [Int: String]?

    /// The type of search
    public var type: String?

    override init() { super.init() }

    public required init?(coder aDecoder: NSCoder) {
        searchText = aDecoder.decodeObject(of: NSString.self, forKey: "searchText") as String?
        type = aDecoder.decodeObject(of: NSString.self, forKey: "type") as String?
        options = aDecoder.decodeObject(of: NSDictionary.self, forKey: "options") as! [Int: String]?
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(searchText, forKey: "searchText")
        aCoder.encode(options, forKey: "options")
        aCoder.encode(type, forKey: "type")
    }

    public static var supportsSecureCoding: Bool = true
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
    
    /// The buttons to be one the right of the search field
    var additionalSearchFieldButtons: [UIButton]? { get }
    
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
    
    /// Do any validation parsing here before a search is performed
    ///
    /// - Parameters:
    ///  - searchable: the searchable
    /// - Returns: if passes validation return nil, else returns an error string
    func passValidation(for searchable: Searchable) -> String?
    
    /// Handle selected options when searchable is selected.
    ///
    /// - Parameters:
    ///   - options: the selected options.
    func setSelectedOptions(options: [Int: String])
    
    /// Notified when becoming active
    ///
    /// - Parameters:
    ///   - viewController: the view controller.
    func didBecomeActive(inViewController viewController: UIViewController)
}

public protocol SearchDataSourceUpdating: class {
    func searchDataSourceRequestDidChange(_ dataSource: SearchDataSource)
    func searchDataSource(_ dataSource: SearchDataSource, didUpdateFilterAt index: Int)
}

public extension SearchDataSource {
    func setSelectedOptions(options: [Int : String]) {}
}
