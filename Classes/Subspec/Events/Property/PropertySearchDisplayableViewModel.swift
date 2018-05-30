//
//  PropertySearchDisplayableViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

class PropertySearchDisplayableViewModel: SearchDisplayableViewModel {
    typealias Object = Property

    var title: String = "Property"
    var hasSections: Bool = true

    let properties: [Property]
    private var filteredProperties: [Property] = []
    private lazy var sectionOrder: [String] = {
        return Array(Set(filteredProperties.map({$0.type})))
    }()

    var isSearching: Bool = false

    init(properties: [Property]) {
        self.properties = properties
        self.filteredProperties = properties
    }

    func numberOfSections() -> Int {
        return sectionOrder.count
    }

    func numberOfRows(in section: Int) -> Int {
        let section = sectionOrder[section]
        return filteredProperties.filter{$0.type == section}.count
    }

    func isSectionHidden(_ section: Int) -> Bool {
        guard isSearching == true else { return false }
        let section = sectionOrder[section]
        return filteredProperties.filter{$0.type == section}.count == 0
    }

    func title(for section: Int) -> String {
        return sectionOrder[section]
    }

    func title(for indexPath: IndexPath) -> String? {
        return object(for: indexPath).fullType
    }

    func object(for indexPath: IndexPath) -> Property {
        let section = sectionOrder[indexPath.section]
        return filteredProperties.filter{$0.type == section}[indexPath.row]
    }

    func searchable(for object: Property) -> CustomSearchDisplayable {
        return PropertyDisplayable(property: object)
    }

    func searchTextChanged(to searchString: String) {
        guard !searchString.isEmpty else {
            isSearching = false
            filteredProperties = properties
            return
        }
        isSearching = true
        filteredProperties = properties.filter{$0.fullType.lowercased().contains(searchString.lowercased())}
    }

    func accessory(for searchable: CustomSearchDisplayable) -> ItemAccessorisable? { return nil }
    func description(for indexPath: IndexPath) -> String? { return nil }
    func image(for indexPath: IndexPath) -> UIImage? { return nil }
    func searchAction() -> Promise<Void>? { return nil }
    func loadingStateText() -> String? { return nil }
    func emptyStateText() -> String? { return nil }
}
