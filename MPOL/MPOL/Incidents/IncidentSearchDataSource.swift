//
//  IncidentSearchDataSource.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

public class IncidentSearchDataSource: CustomSearchPickerDataSource {

    public var objects: [Pickable] = []
    public var selectedObjects: [Pickable]?

    public var title: String?

    public var headerConfiguration: SearchHeaderConfiguration?

    public var header: CustomisableSearchHeaderView?
    public var allowsMultipleSelection: Bool
    public var dismissOnFinish: Bool

    public init(objects: [Pickable],
                selectedObjects: [Pickable]? = nil,
                title: String? = "Incidents",
                allowsMultipleSelection: Bool = true,
                dismissOnFinish: Bool = true,
                configuration: SearchHeaderConfiguration? = nil) {

        self.objects = objects.sorted(using: [SortDescriptor<Pickable>(ascending: true, key: {$0.title }),
                                              SortDescriptor<Pickable>(ascending: true, key: {$0.subtitle })])
        self.selectedObjects = selectedObjects
        self.title = title
        self.allowsMultipleSelection = allowsMultipleSelection
        self.dismissOnFinish = dismissOnFinish
        self.headerConfiguration = configuration
    }

    public func allowsSelection(of object: Pickable) -> Bool {
        return true
    }

    public func updateHeader(for objects: [Pickable]) {
        let config = headerConfiguration
        header?.displayView?.update(with: searchHeaderTitle(with: objects),
                                    subtitle: searchHeaderSubtitle(with: objects),
                                    image: config?.image)
    }

    func searchHeaderTitle(with objects: [Pickable]) -> String {
        return String.localizedStringWithFormat(NSLocalizedString("%d incidents selected", comment: ""), objects.count)
    }

    func searchHeaderSubtitle(with objects: [Pickable]) -> String {
        return objects.map { $0.title }.joined(separator: ", ")
    }
}
