//
//  PersonOptionDataSource.swift
//  MPOL
//
//  Created by Rod Brown on 13/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class PersonSearchDataSource: SearchDataSource {
    
    override class var requestType: SearchRequest.Type {
        return PersonSearchRequest.self
    }

    private var personSearchRequest: PersonSearchRequest = PersonSearchRequest() {
        didSet {
            updatingDelegate?.searchDataSourceRequestDidChange(self)
        }
    }
    
    override var request: SearchRequest {
        get {
            return personSearchRequest
        }
        set {
            guard let newRequest = newValue as? PersonSearchRequest else {
                fatalError("You must not set a request type which is inconsistent with the `requestType` class property")
            }
            personSearchRequest = newRequest
        }
    }
    
    override var localizedDisplayName: String {
        return NSLocalizedString("Person", comment: "")
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
            return personSearchRequest.searchType.title
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
            let values = PersonSearchRequest.SearchType.all
            let picker = PickerTableViewController(style: .plain, items: values)
            picker.title = NSLocalizedString("Search Type", comment: "")
            picker.selectedItems = [personSearchRequest.searchType]
            picker.selectionUpdateHandler = { [weak self] (selectedTypes: Set<PersonSearchRequest.SearchType>?) in
                if let strongSelf = self,
                    let item = selectedTypes?.first {
                    strongSelf.personSearchRequest.searchType = item
                    strongSelf.updatingDelegate?.searchDataSource(strongSelf, didUpdateFilterAt: index)
                }
            }
            viewController = picker
        case .gender:
            let picker = PickerTableViewController(style: .plain, items: Manifest.shared.entries(for: .Genders) ?? [])
            picker.title = NSLocalizedString("Gender/s", comment: "")
            picker.noItemTitle = NSLocalizedString("Any", comment: "")
            // TODO: Handle selection and preselecting
            viewController = picker
        case .state:
            let picker = PickerTableViewController(style: .plain, items: Manifest.shared.entries(for: .States) ?? [])
            picker.title = NSLocalizedString("State/s", comment: "")
            picker.noItemTitle = NSLocalizedString("Any", comment: "")
            // TODO: Handle selection and preselecting
            viewController = picker
        case .age:
            let ageNumberPicker = NumberRangePickerViewController(min:0, max: 100)
            ageNumberPicker.title = NSLocalizedString("Age Range", comment: "")
            ageNumberPicker.noRangeTitle = NSLocalizedString("Any Age", comment: "")
            viewController = ageNumberPicker
        }
        
        return PopoverNavigationController(rootViewController: viewController)
    }
    
    private enum FilterItem: Int {
        case searchType, state, gender, age
        
        static let count = 4
        
        var title: String {
            switch self {
            case .searchType: return NSLocalizedString("Search Type", comment: "")
            case .state:  return NSLocalizedString("State/s",  comment: "")
            case .gender: return NSLocalizedString("Gender/s", comment: "")
            case .age:    return NSLocalizedString("Age",      comment: "")
            }
        }
    }
}
