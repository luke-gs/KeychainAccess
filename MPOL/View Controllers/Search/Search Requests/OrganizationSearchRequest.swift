//
//  OrganizationSearchRequest.swift
//  MPOL
//
//  Created by Rod Brown on 12/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class OrganizationSearchRequest: NSObject, SearchRequest, NSCoding  {
    
    static var localizedDisplayName: String {
        return NSLocalizedString("Organisation", comment: "")
    }
    
    
    var searchText: String?
    
    weak var delegate: SearchRequestDelegate?
    
    
    /// Initialises a new search request, copying common elements from the other search request.
    ///
    /// - Parameter searchRequest: The other search request to copy elements from, or nil
    required init(searchRequest: SearchRequest?) {
        searchText = searchRequest?.searchText
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
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
        return "-"
    }
    
    /// The value specified for the filter, if any.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The value for the filter, if any.
    ///                    Returns `nil` when there is no specific value for the filter.
    func valueForFilter(at index: Int) -> String? {
        return nil
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
