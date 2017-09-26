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
}

public struct SearchResultSection {
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
    
    public init(title: String, entities: [MPOLKitEntity], isExpanded: Bool, state: SearchState, error: Error?) {
        self.title = title
        self.entities = entities
        self.isExpanded = isExpanded
        self.state = state
        self.error = error
    }
}

public protocol SearchResultViewModelDelegate: class {
    func searchResultViewModelDidUpdateResults(_ viewModel: SearchResultViewModelable) -> ()
}

public protocol SearchResultViewModelable: SearchResultModelable {

    /// The style of the results to be shown.
    ///
    /// The current supported styles are grid and list styles. There may be more styles
    /// in the future. Subclass only need to handle these styles for now.
    var style: SearchResultStyle { get set }
    
    /// Contains information for each section
    var results: [SearchResultSection] { get set }
    
    /// A delegate that will be notified when there are changes to results.
    weak var delegate: SearchResultViewModelDelegate? { get set }
    
    /// Registers cells used that will be used by the results.
    func registerCells(for collectionView: UICollectionView)
    
    /// Returns a cell at index path.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, for traitCollection: UITraitCollection) ->
    UICollectionViewCell
    
    /// Returns a minimum width for a cell at index path.
    func collectionView(_ collectionView: UICollectionView, minimumContentWidthForItemAt indexPath: IndexPath, for traitCollection: UITraitCollection) -> CGFloat
    
    /// Returns a minimum height for a cell at index path.
    func collectionView(_ collectionView: UICollectionView, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat, for traitCollection: UITraitCollection) -> CGFloat
    
    /// Retry a specific result section
    func retry(section: Int)
}

