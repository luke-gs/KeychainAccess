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

    public let sort: PickableSorting

    public init(objects: [Pickable],
                selectedObjects: [Pickable] = [],
                title: String? = nil    ,
                allowsMultipleSelection: Bool = false,
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
        return object.title?.caseInsensitiveCompare("reporting officer") != ComparisonResult.orderedSame
    }

    public func updateHeader(for objects: [Pickable]) {
        let config = headerConfiguration
        let subtitle = objects.map { $0.title }.joined(separator: ", ")
        header?.displayView?.update(with: config?.title, subtitle: subtitle.ifNotEmpty() ?? "No selected involvements", image: config?.image)
    }
}
