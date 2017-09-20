//
//  PersonDetailsViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 4/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

/// A base viewModel to provide generic implementation
public class PersonDetailsViewModel<T>: EntityDetailViewModelable {

    /// Generic section type
    public typealias DetailsType = T
    
    /// A delegate for update UI
    weak public var delegate: EntityDetailViewModelDelegate?
    
    public var person: Person? {
        didSet {
            let count = itemsCount()
            delegate?.updateSidebarItemCount(count)
            delegate?.updateNoContentDetails(title: noContentTitle(), subtitle: noContentSubtitle())
        }
    }
    
    public var sections: [DetailsType] = [] {
        didSet {
            let count = sections.count
            delegate?.updateSidebarItemCount(UInt(count))
            
            let state: LoadingStateManager.State  = sections.isEmpty ? .noContent : .loaded
            delegate?.updateLoadingState(state)
            delegate?.reloadData()
        }
    }

    public lazy var collapsedSections: Set<Int> = []
    
    /// A generic section header for collectionView
    /// Subclass needs override to provide custom title
    public var sectionHeader: String? {
        let count = numberOfItems()
        
        if count > 0 {
            let baseString = count > 1 ? NSLocalizedString("%d ITEMS", bundle: .mpolKit, comment: "") : NSLocalizedString("%d ITEM", bundle: .mpolKit, comment: "")
            return String(format: baseString, count)
        }
        return nil
    }
    
    public func items() -> [T]? {
        MPLRequiresConcreteImplementation()
    }
    
    public func itemsCount() -> UInt {
        return UInt(items()?.count ?? 0)
    }
    
    public func noContentTitle() -> String? {
        MPLRequiresConcreteImplementation()
    }
    
    public func noContentSubtitle() -> String? {
        MPLRequiresConcreteImplementation()
    }
    
    public func reloadSections(withFilterDescriptors filters: [FilterDescriptor<T>]?, sortDescriptors: [SortDescriptor<T>]?) {
        var actions = items() ?? []
        
        if let filters = filters {
            actions = actions.filter(using: filters)
        }
        
        if let sorts = sortDescriptors {
            actions = actions.sorted(using: sorts)
        }
        
        sections = actions
        delegate?.updateFilterBarButtonItemActivity()
    }
}
