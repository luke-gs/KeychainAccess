//
//  SearchResultViewModelable.swift
//  MPOLKit
//
//  Created by KGWH78 on 7/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


/// Style that is current supported by the Search results view controller.
public enum SearchResultStyle {
    case grid
    case list
    
    // TODO: Replace with all cases once we hit 4.2
    public static var all: [SearchResultStyle] {
        return [.grid, .list]
    }
}

public class SearchResultSection {
    /// A title text to display in the header.
    public var title:      String
    
    /// Entity
    public var entities:   [MPOLKitEntity]
    
    /// Indicates whether to show the results or hide them.
    ///
    /// The user expand the section by tapping on the header.
    public var isExpanded: Bool
    
    /// States containing the search staus
    public var state:      SearchState
    
    /// Search Error
    public var error:      Error?
    
    /// Source of the section, if applicable
    public var source:     EntitySource?
    
    public init(title: String, entities: [MPOLKitEntity], isExpanded: Bool, state: SearchState, error: Error?, source: EntitySource? = nil) {
        self.title = title
        self.entities = entities
        self.isExpanded = isExpanded
        self.state = state
        self.error = error
        self.source = source
    }
}

extension SearchResultSection: Equatable {

    public static func ==(lhs: SearchResultSection, rhs: SearchResultSection) -> Bool {
        return lhs.title == rhs.title &&
            lhs.entities == rhs.entities &&
            lhs.isExpanded == rhs.isExpanded &&
            lhs.state == rhs.state &&
            (lhs.error as NSError?) == (rhs.error as NSError?)
    }

}

public protocol SearchResultViewModelDelegate: class {

    func searchResultViewModelDidUpdateResults(_ viewModel: SearchResultViewModelable) -> ()

}

public protocol SearchResultViewModelable: SearchResultModelable, ResultViewStylable {
    
    /// Contains information for each section
    var results: [SearchResultSection] { get }
    
    /// Additional actions on search results
    var additionalBarButtonItems: [UIBarButtonItem]? { get set }
    
    /// A delegate that will be notified when there are changes to results.
    var delegate: (SearchResultViewModelDelegate & SearchResultsListViewController)? { get set }

    /// Returns a list of form items for a specific section. This should include a header item if required.
    ///
    /// - Parameter section: The result section to generate the items
    /// - Returns: A collection of form items.
    func itemsForResultsInSection(_ section: SearchResultSection) -> [FormItem]


}

public protocol ResultViewStylable {
    
    /// The style of the results to be shown.
    ///
    /// The current supported styles are grid and list styles. There may be more styles
    /// in the future. Subclass only need to handle these styles for now.
    var style: SearchResultStyle { get }
    
    /// Whitelist of styles that the model responds to
    var allowedStyles: [SearchResultStyle] { get }
    
    /// A style setter that allows us to protect against setting a style that isn't defined
    /// in the allowedStyles array.
    ///
    /// - Returns: Whether the operation was successful.
    @discardableResult
    mutating func setStyleIfAllowed(_ newStyle: SearchResultStyle) -> Bool
}

