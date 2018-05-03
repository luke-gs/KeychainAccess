//
//  RelationshipSearchDatasource.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

public class RelationshipSearchDatasource: CustomSearchPickerDatasource {

    public var objects: [Pickable] = []
    public var selectedObjects: [Pickable] = []

    public var title: String?

    public var headerConfiguration: SearchHeaderConfiguration?

    public var header: CustomisableSearchHeaderView?
    public var allowsMultipleSelection: Bool

    public init(objects: [Pickable],
                selectedObjects: [Pickable] = [],
                title: String? = "Relationships",
                allowsMultipleSelection: Bool = true,
                configuration: SearchHeaderConfiguration? = nil) {

        self.objects = objects.sorted(using: [SortDescriptor<Pickable>(ascending: true, key: {$0.title }),
                                              SortDescriptor<Pickable>(ascending: true, key: {$0.subtitle })])
        self.selectedObjects = selectedObjects
        self.title = title
        self.allowsMultipleSelection = allowsMultipleSelection
        self.headerConfiguration = configuration
    }

    public func allowsSelection(of object: Pickable) -> Bool {
        return true
    }

    public func isValidSelection(for objects: [Pickable]) -> Bool {
        return true
    }

    public func updateHeader(for objects: [Pickable]) {
    }

}
