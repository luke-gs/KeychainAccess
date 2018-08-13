//
//  FancyEntityDetailsViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class EntityDetailsViewModel {

    public let referenceEntity: MPOLKitEntity
    public let datasourceViewModels: [EntityDetailsDatasourceViewModel]

    public var selectedDatasourceViewModel: EntityDetailsDatasourceViewModel {
        return datasourceViewModels.first(where: {$0.datasource.source == currentSource})!
    }

    public var currentSource: EntitySource
    public var selectedSource: EntitySource

    public init(datasourceViewModels: [EntityDetailsDatasourceViewModel],
                initialSource: EntitySource,
                referenceEntity: MPOLKitEntity) {
        self.datasourceViewModels = datasourceViewModels
        self.selectedSource = initialSource
        self.currentSource = initialSource
        self.referenceEntity = referenceEntity
    }
}
