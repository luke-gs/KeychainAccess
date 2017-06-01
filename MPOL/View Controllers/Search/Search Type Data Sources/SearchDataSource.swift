//
//  SearchTypeDataSource.swift
//  MPOL
//
//  Created by Rod Brown on 13/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class SearchDataSource: NSObject {
    
    /// The request for this data source.
    ///
    /// - Important: This is a computed property. All subclasses should override and return a correct type.
    ///              The stored value should always be copied (e.g. @NSCoping), and must
    ///              When setting, this value must pass the `supports(_:)` test.
    var request: SearchRequest {
        get {
            fatalError("SearchDataSource subclasses should return a specific request")
        }
        set {
            fatalError("SearchDataSource subclasses should override and update specific request")
        }
    }
    
    func supports(_ request: SearchRequest) -> Bool {
        return false
    }
    
    /// Resets the request to the default.
    func reset(withSearchText searchText: String? = nil) {
        fatalError("SearchDataSource subclasses should override and reset their requests")
    }
    
    var localizedDisplayName: String {
        return NSLocalizedString("Any Entity", comment: "")
    }
    
    weak var updatingDelegate: SearchDataSourceUpdating?
    
    
    // MARK: - Filters
    
    var numberOfFilters: Int {
        return 0
    }
    
    /// The title for the filter.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The title for the filter.
    func titleForFilter(at index: Int) -> String {
        return ""
    }
    
    /// The value specified for the filter, if any.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The value for the filter, if any.
    ///                    Returns `nil` when there is no specific value for the filter.
    func valueForFilter(at index: Int) -> String? {
        return nil
    }
    
    /// The default value for the filter when there is no specific value.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The default value for the filter.
    func defaultValueForFilter(at index: Int) -> String {
        return "Any"
    }
    
    
    /// The update controller for updating the values in this filter.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The view controller for updating this value.
    ///                    When a standard `UIViewController` is returned, it is expected it will be contained
    ///                    in a `UINavigationController`.
    func updateController(forFilterAt index: Int) -> UIViewController? {
        return nil
    }
    
}


protocol SearchDataSourceUpdating: class {
    
    func searchDataSourceRequestDidChange(_ dataSource: SearchDataSource)
    
    func searchDataSource(_ dataSource: SearchDataSource, didUpdateFilterAt index: Int)
   
}
