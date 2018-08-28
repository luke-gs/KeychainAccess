//
//  GenericSearchViewModel.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

/// Default implementation of The generic search view model
/// Allows for basic customisation
open class DefaultSearchDisplayableViewModel: SearchDisplayableViewModel {
    public typealias Object = CustomSearchDisplayable

    public var title: String = "Search"

    public var hasSections: Bool = true
    public var hidesSections: Bool = true
    public var collapsableSections: Bool = true
    public var sectionPriority: [String] = [String]()

    public var items: [CustomSearchDisplayable]
    private var searchString: String = ""

    private var searchableSections: [String: [CustomSearchDisplayable]] {
        let dict = items.reduce([String: [CustomSearchDisplayable]]()) { (result, item) -> [String: [CustomSearchDisplayable]] in
            let section = item.section ?? "Other"
            var mutableResult = result
            var array = mutableResult[section] ?? [CustomSearchDisplayable]()
            array.append(item)
            mutableResult[section] = array
            return mutableResult
        }

        return dict
    }

    private var prioritisedSections: [PrioritisedSection] {
        let descriptor = SortDescriptor<PrioritisedSection>(ascending: true) { $0.title }

        var validSections = [PrioritisedSection]()
        var invalidSections = [PrioritisedSection]()
        var mutatedSections = searchableSections

        // Add valid sections to prioritised sections in order
        for item in sectionPriority {
            if let sections = mutatedSections.removeValue(forKey: item) {
                validSections.append(PrioritisedSection(title: item, items: sections))
            }
        }

        // If section is not specified for priority, add to bottom of list in whatever order
        for (key, value) in mutatedSections {
            invalidSections.append(PrioritisedSection(title: key, items: value))
        }

        // Sort alphabetically if there are is no section priority
        invalidSections = sectionPriority.count > 0 ? invalidSections : invalidSections.sorted(using: [descriptor])

        return (validSections + invalidSections)
    }

    private func filteredSections() -> [PrioritisedSection] {
        var filteredSections = [PrioritisedSection]()

        for section in prioritisedSections {
            let validItems = section.items.filter{$0.contains(searchString)}
            var section = PrioritisedSection(title: section.title, items: validItems)
            section.isHidden = hidesSections && validItems.count == 0
            filteredSections.append(section)
        }

        return filteredSections
    }

    private var validSections: [PrioritisedSection] {
        return searchString != "" ? filteredSections() : prioritisedSections
    }

    public required init(items: [CustomSearchDisplayable]) {
        self.items = items
    }

    open func searchable(for object: CustomSearchDisplayable) -> CustomSearchDisplayable {
        return object
    }

    open func object(for indexPath: IndexPath) -> CustomSearchDisplayable {
        return searchable(for: validSections[indexPath.section].items[indexPath.item])
    }

    open func numberOfSections() -> Int {
        let sections = validSections
        return sections.count
    }

    open func numberOfRows(in section: Int) -> Int {
        let section = validSections[section]
        return section.items.count
    }

    open func title(for section: Int) -> String {
        let section = validSections[section]
        return section.title
    }

    open func isSectionHidden(_ section: Int) -> Bool {
        return validSections[section].isHidden
    }

    open func title(for indexPath: IndexPath) -> String? {
        let section = validSections[indexPath.section]
        let row = section.items[indexPath.row]
        return row.title
    }

    open func description(for indexPath: IndexPath) -> String? {
        let section = validSections[indexPath.section]
        let row = section.items[indexPath.row]
        return row.subtitle
    }

    open func image(for indexPath: IndexPath) -> UIImage? {
        let section = validSections[indexPath.section]
        let row = section.items[indexPath.row]
        return row.image
    }
    
    open func accessory(for searchable: CustomSearchDisplayable) -> ItemAccessorisable? {
        return ItemAccessory.disclosure
    }

    open func searchTextChanged(to searchString: String) {
        self.searchString = searchString
    }

    open func searchAction() -> Promise<Void>? {
        MPLRequiresConcreteImplementation()
    }

    open func loadingStateText() -> String? {
        return nil
    }

    open func emptyStateText() -> String? {
        return nil
    }
}

/// Generic Search View Model definition
public protocol SearchDisplayableViewModel {

    associatedtype Object

    /// The title of The form
    var title: String { get set }

    /// Whether The collectionView should be seperated by sections
    var hasSections: Bool { get set }

    /// Number of sections
    ///
    /// - Returns: The number of sections
    func numberOfSections() -> Int

    /// Number of rows for a particular sections
    ///
    /// - Parameter section: The section index
    /// - Returns: The number of rows for The section
    func numberOfRows(in section: Int) -> Int

    /// Should section be hidden
    ///
    /// - Parameter section: The section index
    /// - Returns: true if section should be hidden
    func isSectionHidden(_ section: Int) -> Bool

    /// Title for section header
    ///
    /// - Parameter section: The section index
    /// - Returns: The title of The section
    func title(for section: Int) -> String

    /// Title for The row at a specific indexPath
    ///
    /// - Parameter indexPath: The indexPath
    /// - Returns: The title for The row
    func title(for indexPath: IndexPath) -> String?

    /// Description for The row at a specific indexPath
    ///
    /// - Parameter indexPath: The indexPath
    /// - Returns: The description for The row
    func description(for indexPath: IndexPath) -> String?

    /// Image for The row at indexPath
    ///
    /// - Parameter indexPath: The indexPath
    /// - Returns: The image for The row
    func image(for indexPath: IndexPath) -> UIImage?
    
    /// Accessory for The searchable's row.
    /// To be overriden by subclass for custom dynamic accessories.
    ///
    /// - Parameter searchable: The searchable
    /// - Returns: The accessory for The searchable's row
    func accessory(for searchable: CustomSearchDisplayable) -> ItemAccessorisable?

    /// The `GenericSearchable` object for a particular indexPath
    ///
    /// - Parameter indexPath: The indexPath
    /// - Returns: The `GenericSearchable` for The row
    func object(for indexPath: IndexPath) -> Object

    /// Returns The searchable representation of an object
    ///
    /// - Parameter object: The object to convert to generic searchable
    /// - Returns: The generic searchable to display
    func searchable(for object: Object) -> CustomSearchDisplayable

    /// Called when The search text is changed
    ///
    /// - Parameter searchString: The searchString
    func searchTextChanged(to searchString: String)

    /// Called when The search button is selected
    /// Returns an optional promise that can be used to reload The form
    /// after recieving data
    func searchAction() -> Promise<Void>?

    /// The text for The loading state
    ///
    /// - Returns: The loading state text
    func loadingStateText() -> String?

    /// The text for The empty state
    ///
    /// - Returns: The empty state text
    func emptyStateText() -> String?
}

/// A generic searchable object
public protocol CustomSearchDisplayable: CustomSearchPickable {
    /// The section this entity should belong to
    ///
    /// defaults to: `"Other"` if not provided
    var section: String? { get }

    /// The image that should be displayed
    var image: UIImage? { get }
}

private struct PrioritisedSection {
    var title: String
    var items: [CustomSearchDisplayable]
    var isHidden: Bool = false

    init(title: String, items: [CustomSearchDisplayable]) {
        self.title = title
        self.items = items
    }
}

