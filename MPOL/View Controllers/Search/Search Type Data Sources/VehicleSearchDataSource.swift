//
//  VehicleOptionDataSource.swift
//  MPOL
//
//  Created by Rod Brown on 13/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class VehicleSearchDataSource: SearchDataSource {

    override class var requestType: SearchRequest.Type {
        return VehicleSearchRequest.self
    }
    
    private var vehicleSearchRequest = VehicleSearchRequest() {
        didSet {
            updatingDelegate?.searchDataSourceRequestDidChange(self)
        }
    }
    
    override var request: SearchRequest {
        get {
            return vehicleSearchRequest
        }
        set {
            guard let newRequest = newValue as? VehicleSearchRequest else {
                fatalError("You must not set a request type which is inconsistent with the `requestType` class property")
            }
            vehicleSearchRequest = newRequest
        }
    }
    
    override var localizedDisplayName: String {
        return NSLocalizedString("Vehicle", comment: "")
    }
    
    
    // MARK: - Filters
    
    override var numberOfFilters: Int {
        return FilterItem.count
    }
    
    /// The title for the filter.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The title for the filter.
    override func titleForFilter(at index: Int) -> String {
        return FilterItem(rawValue: index)?.title ?? "-"
    }
    
    /// The value specified for the filter, if any.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The value for the filter, if any.
    ///                    Returns `nil` when there is no specific value for the filter.
    override func valueForFilter(at index: Int) -> String? {
        return nil
    }
    
    
    /// The update controller for updating the values in this filter.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The view controller for updating this value.
    ///                    When a standard `UIViewController` is returned, it is expected it will be contained
    ///                    in a `UINavigationController`.
    override func updateController(forFilterAt index: Int) -> UIViewController? {
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
