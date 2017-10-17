//
//  CADFormCollectionViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Delegate for base CAD form collection view models
public protocol CADFormCollectionViewModelDelegate: class {

    // Notify form that sections were updated
    func sectionsUpdated()
}

/// Abstract base class for CAD form collection view models
open class CADFormCollectionViewModel<ItemType> {

    /// Delegate to update form
    public weak var delegate: CADFormCollectionViewModelDelegate?

    // Convenience, public init
    public init() {}

    // MARK: - Abstract

    open var sections: [CADFormCollectionSectionViewModel<ItemType>] = [] {
        didSet {
            delegate?.sectionsUpdated()
        }
    }

    /// The title to use in the navigation bar
    open func navTitle() -> String {
        MPLRequiresConcreteImplementation()
    }

    /// Content title shown when no results
    open func noContentTitle() -> String? {
        MPLRequiresConcreteImplementation()
    }

    open func noContentSubtitle() -> String? {
        MPLRequiresConcreteImplementation()
    }

    // MARK: - Data Source

    private var collapsedSections: Set<Int> = []

    open func numberOfSections() -> Int {
        return sections.count
    }

    open func numberOfItems(for section: Int) -> Int {
        if let sectionViewModel = sections[ifExists: section], !collapsedSections.contains(section) {
            return sectionViewModel.items.count
        }
        return 0
    }

    open func item(at indexPath: IndexPath) -> ItemType? {
        if let sectionViewModel = sections[ifExists: indexPath.section] {
            return sectionViewModel.items[ifExists: indexPath.row]
        }
        return nil
    }

    // MARK: - Group Headers

    open func shouldShowExpandArrow() -> Bool {
        return true
    }

    open func isHeaderExpanded(at section: Int) -> Bool {
        return !collapsedSections.contains(section)
    }

    open func toggleHeaderExpanded(at section: Int) {
        if let itemIndex = collapsedSections.index(of: section) {
            collapsedSections.remove(at: itemIndex)
        } else {
            collapsedSections.insert(section)
        }
    }

    open func headerText(at section: Int) -> String? {
        if let sectionViewModel = sections[ifExists: section] {
            return sectionViewModel.title.uppercased()
        }
        return nil
    }

}
