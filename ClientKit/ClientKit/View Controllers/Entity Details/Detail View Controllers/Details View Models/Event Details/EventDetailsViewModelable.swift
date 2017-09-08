//
//  DetailViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 22/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol EventDetailsViewModelable {
    
    // MARK: Generic properties
    
    /// Generic type for sections
    associatedtype SectionType
    
    /// Generic type for subitems
    associatedtype ItemType

    var event: Event { get }
    /// List of sections
    var sections: [SectionType] { get }
//    weak var delegate: EntityDetailViewModelDelegate? { get }

    
    // MARK: Generic methods
    
    /// Returns the number of sections
    func numberOfSections() -> Int
    
    /// Returns the number of items from a given section
    func numberOfItems(for section: Int) -> Int
    
    /// Asks an item from a section
    func item(at indexPath: IndexPath) -> ItemType?
    
    /// Asks an section from a index
    func section(at index: Int) -> SectionType?
    
}


/// Default Implementation
public extension EventDetailsViewModelable {
    
    // MARK: Default impletation for all generic methods
    
    public func numberOfSections() -> Int {
        return sections.count
    }
    
    public func section(at index: Int) -> SectionType? {
        return sections[ifExists: index]
    }

    
}
