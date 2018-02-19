//
//  IncidentSearchDataSource.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 19/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public class IncidentSearchDataSource: CustomSearchPickerDatasource {

    public var objects: [Pickable] = []
    public var selectedObjects: [Pickable] = []

    public var title: String?

    public var headerConfiguration: SearchHeaderConfiguration?

    public var header: CustomisableSearchHeaderView?
    public var allowsMultipleSelection: Bool

    public let sort: PickableSorting

    public init(objects: [Pickable],
                selectedObjects: [Pickable] = [],
                title: String? = "Incidents",
                allowsMultipleSelection: Bool = true,
                configuration: SearchHeaderConfiguration? = nil,
                sort: PickableSorting = .none) {

        self.objects = objects.sorted(by: sort.function())
        self.selectedObjects = selectedObjects
        self.title = title
        self.allowsMultipleSelection = allowsMultipleSelection
        self.headerConfiguration = configuration
        self.sort = sort
    }

    public func allowsSelection(of object: Pickable) -> Bool {
        return true
    }

    public func updateHeader(for objects: [Pickable]) {
        let config = headerConfiguration
        header?.displayView?.update(with: searchHeaderTitle(),
                                    subtitle: searchHeaderSubtitle(),
                                    image: config?.image)
    }

    func searchHeaderTitle() -> String {
        let multiple = selectedObjects.count > 1
        let countString = selectedObjects.count > 0 ? "NO" : "\(selectedObjects.count)"
        let otherString = "incident\(multiple ? "s" : "") Selected"
        return "\(countString) \(otherString)"
    }

    func searchHeaderSubtitle() -> String {
        return selectedObjects.map{$0.title}.joined(separator: ", ")
    }
}
