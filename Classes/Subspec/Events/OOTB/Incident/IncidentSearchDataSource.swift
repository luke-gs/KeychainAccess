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
        if selectedObjects.contains(where: {$0.title == object.title}) {
            return false
        }

        return true
    }

    public func updateHeader(for objects: [Pickable]) {
        let config = headerConfiguration
        header?.displayView?.update(with: searchHeaderTitle(with: objects),
                                    subtitle: searchHeaderSubtitle(with: objects),
                                    image: config?.image)
    }

    func searchHeaderTitle(with objects: [Pickable]) -> String {
        let string = String.localizedStringWithFormat(NSLocalizedString("%d incidents selected", comment: ""), objects.count)
        return string
    }

    func searchHeaderSubtitle(with objects: [Pickable]) -> String {
        return objects.map{$0.title}.joined(separator: ", ")
    }
}
