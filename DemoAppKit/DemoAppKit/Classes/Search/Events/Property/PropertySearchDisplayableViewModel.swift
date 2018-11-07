//
//  PropertySearchDisplayableViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

public class PropertySearchDisplayableViewModel: SearchDisplayableViewModel {

    public typealias Object = Property

    public var title: String = "Property"
    public var hasSections: Bool = true

    let properties: [Property]
    private var filteredProperties: [Property] = []
    private lazy var sectionOrder: [String] = {
        return Array(Set(filteredProperties.map({$0.type}))).sorted(by: <)
    }()

    var isSearching: Bool = false

    init(properties: [Property]) {
        self.properties = properties
        self.filteredProperties = properties
    }

    public func numberOfSections() -> Int {
        return sectionOrder.count
    }

    public func numberOfRows(in section: Int) -> Int {
        let section = sectionOrder[section]
        return filteredProperties.filter {$0.type == section}.count
    }

    public func isSectionHidden(_ section: Int) -> Bool {
        guard isSearching == true else { return false }
        let section = sectionOrder[section]
        return filteredProperties.filter {$0.type == section}.count == 0
    }

    public func title(for section: Int) -> String {
        return sectionOrder[section]
    }

    public func title(for indexPath: IndexPath) -> StringSizable? {
        return object(for: indexPath).fullType
    }

    public func object(for indexPath: IndexPath) -> Property {
        let section = sectionOrder[indexPath.section]
        return filteredProperties.filter {$0.type == section}[indexPath.row]
    }

    public func searchable(for object: Property) -> CustomSearchDisplayable {
        return PropertyDisplayable(property: object)
    }

    public func searchTextChanged(to searchString: String) {
        guard !searchString.isEmpty else {
            isSearching = false
            filteredProperties = properties
            return
        }
        isSearching = true
        filteredProperties = properties.filter {$0.fullType.lowercased().contains(searchString.lowercased())}
    }

    public func emptyStateTitle() -> String? {
        return "No Property Found"
    }

    open func emptyStateSubtitle() -> String? {
        return nil
    }

    open func emptyStateImage() -> UIImage? {
        return nil
    }

    public func accessory(for searchable: CustomSearchDisplayable) -> ItemAccessorisable? { return nil }
    public func description(for indexPath: IndexPath) -> StringSizable? { return nil }
    public func image(for indexPath: IndexPath) -> UIImage? { return nil }
    public func searchAction() -> Promise<Void>? { return nil }
    public func loadingStateText() -> String? { return nil }
}

internal struct PropertyDisplayable: CustomSearchDisplayable {
    public var title: StringSizable?
    public var subtitle: StringSizable?
    public var section: String?
    public var image: UIImage?

    public init(property: Property) {
        title = property.fullType
        section = property.type
    }

    public func contains(_ searchText: String) -> Bool {
        return title?.sizing().string.contains(searchText) ?? false
    }
}
