//
//  SearchRequest.swift
//  MPOL
//
//  Created by Rod Brown on 12/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


class SearchRequest: NSObject, NSCoding {
    
    class var localizedDisplayName: String {
        return NSLocalizedString("Any Entity", comment: "")
    }
    
    var searchText: String?
    
    weak var delegate: SearchRequestDelegate?
    
    required override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        // TODO
    }
    
    func encode(with aCoder: NSCoder) {
        // TODO
    }
    
    
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
        return NSLocalizedString("Any", comment: "")
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

protocol SearchRequestDelegate: class {
    
    func searchRequest(_ request: SearchRequest, didUpdateFilterAt index: Int)
    
}



