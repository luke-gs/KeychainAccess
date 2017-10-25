//
//  GenericSearchViewModel.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 24/10/17.
//

import UIKit

/// Default implementation of the generic search view model
/// Allows for basic customisation
final public class GenericSearchDefaultViewModel: GenericSearchViewModel {

    public var title: String = "Search"

    public var hasSections: Bool = true
    public var hidesSections: Bool = true
    public var collapsableSections: Bool = true
    public var sectionPriority: [String] = [String]()

    private var items: [GenericSearchable]
    private var searchString: String = ""

    private var searchableSections: [String: [GenericSearchable]] {
        let dict = items.reduce([String: [GenericSearchable]]()) { (result, item) -> [String: [GenericSearchable]] in
            let section = item.section ?? "Other"
            var mutableResult = result
            var array = mutableResult[section] ?? [GenericSearchable]()
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
            let validItems = section.items.filter{$0.matches(searchString: searchString)}
            var section = PrioritisedSection(title: section.title, items: validItems)
            section.isHidden = hidesSections && validItems.count == 0
            filteredSections.append(section)
        }

        return filteredSections
    }

    private var validSections: [PrioritisedSection] {
        return searchString != "" ? filteredSections() : prioritisedSections
    }

    public required init(items: [GenericSearchable]) {
        self.items = items
    }

    public func numberOfSections() -> Int {
        let sections = validSections
        return sections.count
    }

    public func numberOfRows(in section: Int) -> Int {
        let section = validSections[section]
        return section.items.count
    }

    public func title(for section: Int) -> String {
        let section = validSections[section]
        return section.title
    }

    public func isSectionHidden(_ section: Int) -> Bool {
        return validSections[section].isHidden
    }

    public func title(for indexPath: IndexPath) -> String {
        let section = validSections[indexPath.section]
        let row = section.items[indexPath.row]
        return row.title
    }

    public func description(for indexPath: IndexPath) -> String? {
        let section = validSections[indexPath.section]
        let row = section.items[indexPath.row]
        return row.subtitle
    }

    public func image(for indexPath: IndexPath) -> UIImage? {
        let section = validSections[indexPath.section]
        let row = section.items[indexPath.row]
        return row.image
    }

    public func searchable(for indexPath: IndexPath) -> GenericSearchable {
        let section = validSections[indexPath.section]
        return section.items[indexPath.row]
    }

    public func searchTextChanged(to searchString: String) {
        self.searchString = searchString
    }

}

/// Generic Search View Model definition
public protocol GenericSearchViewModel {

    /// The title of the form
    var title: String { get set }

    /// Whether the collectionView should be seperated by sections
    var hasSections: Bool { get set }

    /// Number of sections
    ///
    /// - Returns: the number of sections
    func numberOfSections() -> Int

    /// Number of rows for a particular sections
    ///
    /// - Parameter section: the section index
    /// - Returns: the number of rows for the section
    func numberOfRows(in section: Int) -> Int

    /// Should section be hidden
    ///
    /// - Parameter section: the section index
    /// - Returns: true if section should be hidden
    func isSectionHidden(_ section: Int) -> Bool

    /// Title for section header
    ///
    /// - Parameter section: the section index
    /// - Returns: the title of the section
    func title(for section: Int) -> String

    /// Title for the row at a specific indexPath
    ///
    /// - Parameter indexPath: the indexPath
    /// - Returns: the title for the row
    func title(for indexPath: IndexPath) -> String

    /// Description for the row at a specific indexPath
    ///
    /// - Parameter indexPath: the indexPath
    /// - Returns: the description for the row
    func description(for indexPath: IndexPath) -> String?

    /// Image for the row at indexPath
    ///
    /// - Parameter indexPath: the indexPath
    /// - Returns: the image for the row
    func image(for indexPath: IndexPath) -> UIImage?

    /// The `GenericSearchable` object for a particular indexPath
    ///
    /// - Parameter indexPath: the indexPath
    /// - Returns: the `GenericSearchable` for the row
    func searchable(for indexPath: IndexPath) -> GenericSearchable

    /// Called when the search text is changed
    ///
    /// - Parameter searchString: the searchString
    func searchTextChanged(to searchString: String)
}

/// A generic searchable object
public protocol GenericSearchable {

    /// The main string to display
    var title: String { get }

    /// The subtitle string to display
    var subtitle: String? { get }

    /// The section this entity should belong to
    ///
    /// defaults to: `"Other"` if not provided
    var section: String? { get }

    /// The image that should be displayed
    var image: UIImage? { get }

    /// Perform business logic here to check if the entity should show up when filtering
    ///
    /// - Parameter searchString: the search string that is currently being filtered with
    /// - Returns: true if should check passes and entity should be displayed
    func matches(searchString: String) -> Bool
}

private struct PrioritisedSection {
    var title: String
    var items: [GenericSearchable]
    var isHidden: Bool = false

    init(title: String, items: [GenericSearchable]) {
        self.title = title
        self.items = items
    }
}

