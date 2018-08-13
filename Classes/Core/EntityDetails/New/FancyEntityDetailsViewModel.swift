//
//  FancyEntityDetailsViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class FancyEntityDetailsViewModel {

    public let referenceEntity: MPOLKitEntity
    public let datasourceViewModels: [FancyEntityDetailsDatasourceViewModel]

    public var selectedDatasourceViewModel: FancyEntityDetailsDatasourceViewModel {
        return datasourceViewModels.first(where: {$0.datasource.source == currentSource})!
    }

    public var currentSource: EntitySource
    public var selectedSource: EntitySource

    public init(datasourceViewModels: [FancyEntityDetailsDatasourceViewModel],
                initialSource: EntitySource,
                referenceEntity: MPOLKitEntity) {
        self.datasourceViewModels = datasourceViewModels
        self.selectedSource = initialSource
        self.currentSource = initialSource
        self.referenceEntity = referenceEntity
    }
}
