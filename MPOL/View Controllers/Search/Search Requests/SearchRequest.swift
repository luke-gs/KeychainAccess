//
//  SearchRequest.swift
//  MPOL
//
//  Created by Rod Brown on 12/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


protocol SearchRequest: class, NSCoding {
    
    static var localizedDisplayName: String { get }
    
    
    var searchText: String? { get set }
    
    weak var delegate: SearchRequestDelegate? { get set }
    
    
    /// Initialises a new search request, copying common elements from the other search request.
    ///
    /// - Parameter searchRequest: The other search request to copy elements from, or nil
    init(searchRequest: SearchRequest?)
    
    
    
    // MARK: - Filters
    
    var numberOfFilters: Int { get }
    
    /// The title for the filter.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The title for the filter.
    func titleForFilter(at index: Int) -> String
    
    /// The value specified for the filter, if any.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The value for the filter, if any.
    ///                    Returns `nil` when there is no specific value for the filter.
    func valueForFilter(at index: Int) -> String?
    
    /// The default value for the filter when there is no specific value.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The default value for the filter.
    func defaultValueForFilter(at index: Int) -> String
    
    
    /// The update controller for updating the values in this filter.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The view controller for updating this value.
    ///                    When a standard `UIViewController` is returned, it is expected it will be contained
    ///                    in a `UINavigationController`.
    func updateController(forFilterAt index: Int) -> UIViewController?
    
}

extension SearchRequest {
    
    func defaultValueForFilter(at index: Int) -> String {
        return NSLocalizedString("Any", comment: "")
    }
    
}

protocol SearchRequestDelegate: class {
    
    func searchRequest(_ request: SearchRequest, didUpdateFilterAt index: Int)
    
}



