//
//  RelationshipSearchDataSource.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

import PublicSafetyKit

public class RelationshipSearchDataSource: CustomSearchPickerDataSource {

    public var objects: [Pickable] = []
    public var selectedObjects: [Pickable]?

    public var title: String?

    public var headerConfiguration: SearchHeaderConfiguration?

    public var header: CustomisableSearchHeaderView?
    public var allowsMultipleSelection: Bool
    public var dismissOnFinish: Bool

    public init(objects: [Pickable],
                selectedObjects: [Pickable]? = nil,
                title: String? = "Relationships",
                allowsMultipleSelection: Bool = true,
                dismissOnFinish: Bool = true,
                configuration: SearchHeaderConfiguration? = nil) {

        self.objects = objects.sorted(using: [SortDescriptor<Pickable>(ascending: true, key: {$0.title?.sizing().string }),
                                              SortDescriptor<Pickable>(ascending: true, key: {$0.subtitle?.sizing().string })])
        self.selectedObjects = selectedObjects
        self.title = title
        self.allowsMultipleSelection = allowsMultipleSelection
        self.dismissOnFinish = dismissOnFinish
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
