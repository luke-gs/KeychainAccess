//
//  DefaultPickableSearchDatasource.swift
//  MPOL
//
//  Created by QHMW64 on 12/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public class DefaultPickableSearchDatasource: CustomSearchPickerDatasource {

    public var objects: [Pickable] = []
    public var selectedObjects: [Pickable]?

    public var title: String?

    public var headerConfiguration: SearchHeaderConfiguration?

    public var header: CustomisableSearchHeaderView?
    public var allowsMultipleSelection: Bool
    public var requiresSelection: Bool
    public var dismissOnFinish: Bool

    public init(objects: [Pickable],
                selectedObjects: [Pickable]? = nil,
                title: String? = "",
                allowsMultipleSelection: Bool = true,
                requiresSelection: Bool = true,
                dismissOnFinish: Bool = true,
                configuration: SearchHeaderConfiguration? = nil) {
        
        self.objects = objects.sorted(using: [SortDescriptor<Pickable>(ascending: true, key: { $0.title }),
                                               SortDescriptor<Pickable>(ascending: true, key: { $0.subtitle })])
        self.selectedObjects = selectedObjects
        self.title = title
        self.allowsMultipleSelection = allowsMultipleSelection
        self.requiresSelection = requiresSelection
        self.dismissOnFinish = dismissOnFinish
        self.headerConfiguration = configuration
    }

    public func allowsSelection(of object: Pickable) -> Bool {
        return true
    }

    public func updateHeader(for objects: [Pickable]) {
        let config = headerConfiguration
        let subtitle = objects.map { $0.title }.joined(separator: ", ")
        let displayText: String = self.title == nil ? "" : "No Selected \(self.title!.capitalized)"
        header?.displayView?.update(with: config?.title, subtitle: subtitle.ifNotEmpty() ?? displayText, image: config?.image)
    }

    public func isValidSelection(for objects: [Pickable]) -> Bool {

        if requiresSelection {
            return objects.count > 0
        } else {
            return true
        }
    }
}
