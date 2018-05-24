//
//  DefaultSearchPickerDatasource.swift
//  MPOLKit
//
//  Created by QHMW64 on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public class DefaultSearchDatasource: CustomSearchPickerDatasource {

    public var objects: [Pickable] = []
    public var selectedObjects: [Pickable]?

    public var title: String?

    public var headerConfiguration: SearchHeaderConfiguration?

    public var header: CustomisableSearchHeaderView?
    public var allowsMultipleSelection: Bool

    public init(objects: [Pickable],
                selectedObjects: [Pickable]? = nil,
                title: String? = nil    ,
                allowsMultipleSelection: Bool = false,
                configuration: SearchHeaderConfiguration? = nil) {

        self.objects = objects
        self.selectedObjects = selectedObjects
        self.title = title
        self.allowsMultipleSelection = allowsMultipleSelection
        self.headerConfiguration = configuration
    }

    public func allowsSelection(of object: Pickable) -> Bool {
        return true
    }

    public func updateHeader(for objects: [Pickable]) {
        let config = headerConfiguration
        let subtitle = objects.map { $0.title }.joined(separator: ", ")
        header?.displayView?.update(with: config?.title, subtitle: subtitle.ifNotEmpty() ?? "No selected involvements", image: config?.image)
    }
}
