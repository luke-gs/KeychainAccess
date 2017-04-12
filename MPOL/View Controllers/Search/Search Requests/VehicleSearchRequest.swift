//
//  VehicleSearchRequest.swift
//  MPOL
//
//  Created by Rod Brown on 12/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class VehicleSearchRequest: NSObject, SearchRequest, NSCoding {
    
    static var localizedDisplayName: String {
        return NSLocalizedString("Vehicle", comment: "")
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
        return FilterItem.count
    }
    
    /// The title for the filter.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The title for the filter.
    func titleForFilter(at index: Int) -> String {
        return FilterItem(rawValue: index)?.title ?? "-"
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
    
    
    private enum FilterItem: Int {
        case searchType, state, make, model
        
        static let count = 4
        
        var title: String {
            switch self {
            case .searchType: return NSLocalizedString("Search Type", comment: "")
            case .state: return NSLocalizedString("State/s",  comment: "")
            case .make:  return NSLocalizedString("Make",     comment: "")
            case .model: return NSLocalizedString("Model",    comment: "")
            }
        }
    }
    
}
