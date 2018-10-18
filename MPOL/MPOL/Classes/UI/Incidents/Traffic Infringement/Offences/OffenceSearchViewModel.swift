//
//  OffenceSearchViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit
import PublicSafetyKit

public class OffenceSearchViewModel: SearchDisplayableViewModel {
    public typealias Object = Offence

    public var title: String = "Add Offence"
    public var hasSections: Bool = false

    private var objectDisplayMap: [Object: CustomSearchDisplayable] = [:]
    public private(set) var items: [Object] = []
    private var filteredItems: [Object] = []

    public init(items: [Object]) {
        self.items = items
        filteredItems = self.items
    }

    public func numberOfSections() -> Int {
        return 1
    }

    public func numberOfRows(in section: Int) -> Int {
        return filteredItems.count
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
        return filteredItems[indexPath.row]
    }

    public func searchable(for object: Offence) -> CustomSearchDisplayable {
        if let displayable = objectDisplayMap[object] {
            return displayable
        } else {
            let newDisplayable = OffenceListDisplayable(offence: object)
            objectDisplayMap[object] = newDisplayable
            return newDisplayable
        }
    }

    public func searchTextChanged(to searchString: String) {
        if searchString.isEmpty {
            //if string is empty, set filtered back to base copy
            filteredItems = self.items
        } else {
            filteredItems = items.filter {$0.title.lowercased().contains(searchString.lowercased())}
        }
    }

    public func searchAction() -> Promise<Void>? {
        //TODO: Implement search action to pull from server, if required
        return nil
    }

    public func loadingStateText() -> String? {
        return nil
    }

    public func emptyStateText() -> String? {
        return "No Recently Used Offences"
    }
}
