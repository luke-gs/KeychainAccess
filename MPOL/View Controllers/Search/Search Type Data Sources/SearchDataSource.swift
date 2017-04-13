//
//  SearchTypeDataSource.swift
//  MPOL
//
//  Created by Rod Brown on 13/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class SearchDataSource: NSObject {
    
    dynamic class var requestType: SearchRequest.Type {
        return SearchRequest.self
    }
    
    /// The request for this data source.
    ///
    /// - Important: This is a computed property. All subclasses should override and return a correct type.
    ///              This must be of the class, or a subclass of, the request type specified
    ///              by the class variable `SearchDataSource.requestType`.
    var request: SearchRequest {
        get {
            fatalError("SearchDataSource subclasses should return a specific request")
        }
        set {
            fatalError("SearchDataSource subclasses should override and update specific request")
        }
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
