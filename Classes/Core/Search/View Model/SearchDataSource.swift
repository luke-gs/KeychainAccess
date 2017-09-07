//
//  SearchTypeDataSource.swift
//  MPOL
//
//  Created by Rod Brown on 13/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A searchable object. 
/// The datasource should know the options and types and what to do with them
public class Searchable: NSObject, NSSecureCoding {

    /// The search text
    public var text: String?

    /// The filter options.
    /// - Key: the index of the filter
    /// - Value: the value of the filter
    public var options: [Int: String]?

    /// The type of search
    public var type: String?

    override init() { super.init() }

    public init(text: String? = nil, options: [Int: String]? = nil, type: String? = nil) {
        self.text = text
        self.options = options
        self.type = type
    }

    public required init?(coder aDecoder: NSCoder) {
        text = aDecoder.decodeObject(of: NSString.self, forKey: "searchText") as String?
        type = aDecoder.decodeObject(of: NSString.self, forKey: "type") as String?
        options = aDecoder.decodeObject(of: NSDictionary.self, forKey: "options") as! [Int: String]?
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(text, forKey: "searchText")
        aCoder.encode(options, forKey: "options")
        aCoder.encode(type, forKey: "type")
    }

    public static var supportsSecureCoding: Bool = true
}

public func ==(lhs: Searchable, rhs: Searchable) -> Bool {
    if lhs.text != rhs.text || lhs.type != rhs.type {
        return false
    }
    
    let lhsOptions = lhs.options
    let rhsOptions = rhs.options
    
    if let lhsOptions = lhsOptions, let rhsOptions = rhsOptions {
        return lhsOptions == rhsOptions
    } else if lhsOptions != nil || rhsOptions != nil {
        return false
    }
    
    return true
}

public enum SearchFieldStyle {
    case search(configure: ((UITextField) -> [UIButton]?)?,
                textHandler: ((_ text: String?, _ endEditing: Bool) -> ())?,
                errorMessage: String?)
    case button(configure: ((UIButton) -> ())?)
}

public enum SearchOptionType {
    case picker
    case text(configure: ((UITextField) -> ())?)
    case action(image: UIImage?, buttonTitle: String?, buttonHandler: (() ->())?)
}

public protocol SearchOptions {
    /// The header text
    var headerText: String? { get }

    /// The number of filters for this data source
    var numberOfOptions: Int { get }

    /// The title for the filter.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The title for the filter.
    func title(at index: Int) -> String

    /// The value specified for the filter, if any.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The value for the filter, if any.
    ///                    Returns `nil` when there is no specific value for the filter.
    func value(at index: Int) -> String?

    /// The default value for the filter when there is no specific value.
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The default value for the filter.
    func defaultValue(at index: Int) -> String
    
    /// The error message for the filter
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The error message.
    func errorMessage(at index: Int) -> String?
    
    /// The type for the filter
    ///
    /// - Parameter index: The filter index.
    /// - Returns:         The filter type.
    func type(at index: Int) -> SearchOptionType
    
}

public protocol SearchDataSource: class {
    /// The search style 
    var searchStyle: SearchFieldStyle { get }

    /// The filter object used to declare all filtering rules
    var options: SearchOptions? { get }
    
    /// The localized display name for the datasource. Used as the title in the search options view controller.
    var localizedDisplayName: String { get }

    /// The search button to be displayed in the navigation bar.
    var navigationButton: UIBarButtonItem? { get }
    
    /// The updating delegate is set on becoming active in the SearchOptionsViewController 
    /// and is guaranteed to be a kind of UIViewController.
    ///
    /// FIXME: This will be constrained to be a UIViewController and SearchDataSourceUpdating in Swift 4.
    weak var updatingDelegate: SearchDataSourceUpdating? { get set }

    /// The action for filter. The method is called on selection of each option field. Typically used
    /// to generate dropdown action. But the datasource can intercept and perform other task if required.
    ///
    /// - Parameters:
    ///   - index: The filter index.
    /// - Returns: The option action.
    func selectionAction(forFilterAt index: Int) -> SearchOptionAction
    
    /// Handle value changed. The method is called if and only if the option at the index has the type of 'text'.
    ///
    /// - Parameters:
    ///   - index: The filter index.
    ///   - text: The text entered.
    ///   - ended: Indicates the end of editing.
    func textChanged(forFilterAt index: Int, text: String?, didEndEditing ended: Bool)
    
    /// Prefills search with existing search. Datasource can choose to ignore the existing search
    /// if it doesn't satisfy the format requirement. Return true if the search is processed and 
    /// accepted by the datasource. False to indicate that it has been rejected.
    /// 
    /// - Parameters:
    ///   - searchable: The searchable.
    /// - Returns: True if searchable is accepted by the datasource. False otherwise.
    @discardableResult func prefill(withSearchable searchable: Searchable) -> Bool
}

/// This specifies the action that should occur when an option is selected.
public enum SearchOptionAction {
    /// No action to be taken.
    case none
    
    /// The view controller for updating the value. Used on picker selection.
    case options(controller: UIViewController?)
}

public enum SearchDataSourceComponent {
    /// All components of the SearchDataSource.
    case all
    
    /// The search style. Refers to 'SearchFieldStyle'
    case searchStyle
    
    /// The message of the SearchFieldStyle. Use this to avoid reloading issue.
    case searchStyleErrorMessage
    
    /// The filter at a specific index. Pass nil as index to indicate all filters.
    case filter(index: Int?)
    
    /// The error message of a filter at a specific index. Use this to avoid reloading issue.
    case filterErrorMessage(index: Int)
}

public protocol SearchDataSourceUpdating: class {
    func searchDataSource(_ dataSource: SearchDataSource, didUpdateComponent component: SearchDataSourceComponent)
    
    func searchDataSource(_ dataSource: SearchDataSource, didFinishWith search: Searchable?, andResultViewModel viewModel: SearchResultModelable?)
}

/// Default implementations of the SearchDataSource
public extension SearchDataSource {
    /// Default to search style.
    var searchStyle: SearchFieldStyle { return .search(configure: nil, textHandler: nil, errorMessage: nil) }
    
    /// Default selection action is '.none'.
    func selectionAction(forFilterAt index: Int) -> SearchOptionAction { return .none }
    
    /// Default text handling to do nothing.
    func textChanged(forFilterAt index: Int, text: String?, didEndEditing ended: Bool) { }
    
    /// Default to false
    func prefill(withSearchable searchable: Searchable) -> Bool { return false }
}

/// Default implementations of the SearchOptions
public extension SearchOptions {
    /// Default header text is 'SEARCH FILTER'.
    var headerText: String? { return NSLocalizedString("SEARCH FILTER", comment: "Search - Search Filter title") }
    
    /// Gets the current state of the search options.
    ///
    /// - Returns: A representation of the search options in a dictionary format.
    func state() -> [Int: String]? {
        guard numberOfOptions > 0 else { return nil }
        
        var state = [Int: String]()
        for index in 0..<numberOfOptions {
            state[index] = value(at: index)
        }
        
        return state.isEmpty ? nil : state
    }
    
}

/// Convenient helpers
public extension SearchDataSource {
    
    /// Creates a picker controller.
    /// 
    /// - Parameters:
    ///   - index: The filter index.
    ///   - items: Items to display in the list.
    ///   - selectedIndexes: The selected indexes.
    ///   - onSelect: The selection handler.
    /// - Returns: PopoverNavigationController
    func pickerController<T>(forFilterAt index: Int, items: [T], selectedIndexes: IndexSet, onSelect: ((PickerTableViewController<T>, IndexSet) -> ())?) -> PopoverNavigationController {
        
        let picker = PickerTableViewController(style: .plain, items: items)
        picker.selectedIndexes = selectedIndexes
        picker.selectionUpdateHandler = { [unowned self] (picker, selectedIndexes) in
            onSelect?(picker, selectedIndexes)
            
            self.updatingDelegate?.searchDataSource(self, didUpdateComponent: .filter(index: index))
            picker.dismiss(animated: true, completion: nil)
        }
        picker.title = options?.title(at: index)
        return PopoverNavigationController(rootViewController: picker)
    }
    
}
