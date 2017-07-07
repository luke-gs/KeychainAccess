//
//  VehicleOptionDataSource.swift
//  MPOL
//
//  Created by Rod Brown on 13/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class VehicleSearchDataSource: SearchDataSource {
    
    @NSCopying private var vehicleSearchRequest = VehicleSearchRequest() {
        didSet {            
            updatingDelegate?.searchDataSourceRequestDidChange(self)
        }
    }
    
    override var request: SearchRequest {
        get {
            return vehicleSearchRequest
        }
        set {
            guard let newRequest = newValue as? VehicleSearchRequest, supports(newRequest) else {
                fatalError("You must not set a request the data source doesn't support.")
            }
            vehicleSearchRequest = newRequest
        }
    }
    
    override func supports(_ request: SearchRequest) -> Bool {
        return request is VehicleSearchRequest
    }
    
    override func reset(withSearchText searchText: String?) {
        vehicleSearchRequest = VehicleSearchRequest(searchText: searchText)
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
        guard let filterItem = FilterItem(rawValue: index) else { return nil }
        
        switch filterItem {
        case .searchType:
            return vehicleSearchRequest.searchType.title
        default:
            return nil
        }
    }
    
    
    /// The update controller for updating the values in this filter.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The view controller for updating this value.
    ///                    When a standard `UIViewController` is returned, it is expected it will be contained
    ///                    in a `UINavigationController`.
    override func updateController(forFilterAt index: Int) -> UIViewController? {
        guard let item = FilterItem(rawValue: index) else { return nil }
        let viewController: UIViewController
        
        switch item {
        case .searchType:
            let searchTypes = VehicleSearchRequest.SearchType.all
            
            let picker = PickerTableViewController(style: .plain, items: searchTypes)
            picker.selectedIndexes = searchTypes.indexes { $0 == vehicleSearchRequest.searchType }
            picker.selectionUpdateHandler = { [weak self] (_, selectedIndexes) in
                guard let `self` = self, let selectedTypeIndex = selectedIndexes.first else { return }
                
                self.vehicleSearchRequest.searchType = searchTypes[selectedTypeIndex]
                self.updatingDelegate?.searchDataSource(self, didUpdateFilterAt: index)
            }
            viewController = picker
        case .state:
            let states = Manifest.shared.entries(for: .States) ?? []
            
            let picker = PickerTableViewController(style: .plain, items: states )
            picker.noItemTitle   = NSLocalizedString("Any", comment: "")
            
            let currentStates = Set(vehicleSearchRequest.states?.flatMap({ $0.current() }) ?? [])
            picker.selectedIndexes = states.indexes { currentStates.contains($0) }
            
            picker.selectionUpdateHandler = { [weak self] (_, selectedIndexes) in
                guard let `self` = self else { return }
                
                self.vehicleSearchRequest.states = states[selectedIndexes].flatMap { ArchivedManifestEntry(entry: $0) }
                self.updatingDelegate?.searchDataSource(self, didUpdateFilterAt: index)
            }
            
            viewController = picker
        case .make:
            let picker = PickerTableViewController(style: .plain, items: [ManifestEntry]())
            picker.noItemTitle = NSLocalizedString("Any", comment: "")
            // TODO: Handle selection and preselecting
            viewController = picker
        case .model:
            let picker = PickerTableViewController(style: .plain, items: [ManifestEntry]())
            picker.noItemTitle = NSLocalizedString("Any", comment: "")
            // TODO: Handle selection and preselecting
            viewController = picker
        }
        viewController.title = item.title
        
        return PopoverNavigationController(rootViewController: viewController)
    }


    private enum FilterItem: Int {
        case searchType, state, make, model
        
        static let count = 4
        
        var title: String {
            switch self {
            case .searchType: return NSLocalizedString("Search Type", comment: "")
            case .state:      return NSLocalizedString("State/s",  comment: "")
            case .make:       return NSLocalizedString("Make",     comment: "")
            case .model:      return NSLocalizedString("Model",    comment: "")
            }
        }
    }
    
}
