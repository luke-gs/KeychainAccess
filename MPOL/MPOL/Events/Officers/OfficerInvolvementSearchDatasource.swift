//
//  OfficerSearchDatasource.swift
//  MPOL
//
//  Created by QHMW64 on 12/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class OfficerInvolvementSearchDatasource: CustomSearchPickerDatasource {

    public var objects: [Pickable] = []
    public var selectedObjects: [Pickable] = []

    public var title: String?

    public var headerConfiguration: SearchHeaderConfiguration?

    public var header: CustomisableSearchHeaderView?
    public var allowsMultipleSelection: Bool

    public init(objects: [Pickable],
                selectedObjects: [Pickable] = [],
                title: String? = "Involvements",
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

    public func updateHeader(for objects: [Pickable]) {
        let config = headerConfiguration
        let subtitle = objects.map { $0.title }.joined(separator: ", ")
        header?.displayView?.update(with: config?.title, subtitle: subtitle.ifNotEmpty() ?? "No selected involvements", image: config?.image)
    }
}
