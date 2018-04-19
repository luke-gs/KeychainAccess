//
//  OffenceSearchViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit
import MPOLKit

public class OffenceSearchViewModel : SearchDisplayableViewModel {

    public typealias Object = Offence

    public var title: String = "Add Offence"

    public var hasSections: Bool = false

    private var objectDisplayMap: [Object: CustomSearchDisplayable] = [:]
    public private(set) var items: [Object] = []

    public init(items: [Object] = []) {
        self.items = items
    }

    public func numberOfSections() -> Int {
        return 1
    }

    public func numberOfRows(in section: Int) -> Int {
        return items.count
    }

    public func isSectionHidden(_ section: Int) -> Bool {
        return false
    }

    public func title(for section: Int) -> String {
        return ""
    }

    public func title(for indexPath: IndexPath) -> String? {
        return searchable(for: object(for: indexPath)).title
    }

    public func description(for indexPath: IndexPath) -> String? {
        return searchable(for: object(for: indexPath)).subtitle
    }

    public func image(for indexPath: IndexPath) -> UIImage? {
        return nil
    }

    public func accessory(for searchable: CustomSearchDisplayable) -> ItemAccessorisable? {
        //TODO: Implement a "selectButton" type for ItemAccessory
        return ItemAccessory.disclosure
    }

    public func object(for indexPath: IndexPath) -> Offence {
        return items[indexPath.row]
    }

    public func searchable(for object: Offence) -> CustomSearchDisplayable {
        if let existingSearchable = objectDisplayMap[object] {
            return existingSearchable
        }
        let searchable = OffenceListDisplayable(offence: object)
        objectDisplayMap[object] = searchable
        return searchable
    }

    public func searchTextChanged(to searchString: String) {

    }

    public func searchAction() -> Promise<Void>? {
        fatalError()
    }


}
