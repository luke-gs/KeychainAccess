//
//  PersonOptionDataSource.swift
//  MPOL
//
//  Created by Rod Brown on 13/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class PersonSearchDataSource: SearchDataSource, NumberRangePickerDelegate {
    
    private enum FilterItem: Int {
        case searchType, state, gender, age
        
        static let count = 4
        
        var title: String {
            switch self {
            case .searchType: return NSLocalizedString("Search Type", comment: "")
            case .state:      return NSLocalizedString("State/s",  comment: "")
            case .gender:     return NSLocalizedString("Gender/s", comment: "")
            case .age:        return NSLocalizedString("Age",      comment: "")
            }
        }
        
        fileprivate var pickerTitle: String {
            switch self {
            case .searchType: return NSLocalizedString("Search Type", comment: "")
            case .state:      return NSLocalizedString("State/s",  comment: "")
            case .gender:     return NSLocalizedString("Gender/s", comment: "")
            case .age:        return NSLocalizedString("Age Range",      comment: "")
            }
        }
    }
    
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
        case .age:
            if let ageRange = personSearchRequest.ageRange {
                if ageRange.lowerBound == ageRange.upperBound {
                    return "\(ageRange.lowerBound)"
                }
                
                return "\(ageRange.lowerBound) - \(ageRange.upperBound)"
            }
            return nil
        case .gender:
            return personSearchRequest.gender?.description
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
            let picker = PickerTableViewController(style: .plain, items: Person.Gender.allCases)
            picker.title = NSLocalizedString("Gender/s", comment: "")
            picker.noItemTitle = NSLocalizedString("Any", comment: "")
            if let gender = personSearchRequest.gender {
                picker.selectedItems = [gender]
            }
            
            picker.selectionUpdateHandler = { [weak self] (items) in
                guard let `self` = self else { return }
                
                self.personSearchRequest.gender = items?.first
                self.updatingDelegate?.searchDataSource(self, didUpdateFilterAt: index)
            }
            
            // TODO: Handle selection
            viewController = picker
        case .state:
            let picker = PickerTableViewController(style: .plain, items: Manifest.shared.entries(for: .States) ?? [])
            picker.noItemTitle   = NSLocalizedString("Any", comment: "")
            picker.selectedItems = Set(personSearchRequest.states?.flatMap { $0.current() } ?? [])
            
            picker.selectionUpdateHandler = { [weak self] (items) in
                guard let `self` = self else { return }
                
                self.personSearchRequest.states = items?.flatMap { ArchivedManifestEntry(entry: $0) }
                self.updatingDelegate?.searchDataSource(self, didUpdateFilterAt: index)
            }
            
            viewController = picker
        case .age:
            let ageNumberPicker = NumberRangePickerViewController(min:0, max: 100)
            ageNumberPicker.delegate = self
            ageNumberPicker.noRangeTitle = NSLocalizedString("Any Age", comment: "")
            
            if let ageRange = personSearchRequest.ageRange {
                ageNumberPicker.currentMinValue = ageRange.lowerBound
                ageNumberPicker.currentMaxValue = ageRange.upperBound
            } else {
                // Workaround:
                // Delay the update until the presentation UI is in place.
                // Reloading during selection causes bugs in UICollectionView.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.personSearchRequest.ageRange = Range<Int>(uncheckedBounds: (ageNumberPicker.currentMinValue, ageNumberPicker.currentMaxValue))
                    self.updatingDelegate?.searchDataSource(self, didUpdateFilterAt: FilterItem.age.rawValue)
                }
            }
            
            viewController = ageNumberPicker
        }
        viewController.title = item.pickerTitle
        
        return PopoverNavigationController(rootViewController: viewController)
    }
    
    
    
    // MARK: - Number range picker delegate
    
    func numberRangePicker(_ numberPicker: NumberRangePickerViewController, didUpdateMinValue minValue: Int, maxValue: Int) {
        let newRange = Range<Int>(uncheckedBounds: (minValue, maxValue))
        if personSearchRequest.ageRange != newRange {
            personSearchRequest.ageRange = newRange
            updatingDelegate?.searchDataSource(self, didUpdateFilterAt: FilterItem.age.rawValue)
        }
    }
    
    func numberRangePickerDidSelectNoRange(_ picker: NumberRangePickerViewController) {
        if personSearchRequest.ageRange != nil {
            personSearchRequest.ageRange = nil
            updatingDelegate?.searchDataSource(self, didUpdateFilterAt: FilterItem.age.rawValue)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
}
