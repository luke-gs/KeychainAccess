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
        return datasourceViewModels.first(where: {$0.datasource.source == selectedSource})!
    }

    public var selectedSource: EntitySource

    public init(datasourceViewModels: [FancyEntityDetailsDatasourceViewModel],
                initialSource: EntitySource,
                referenceEntity: MPOLKitEntity) {
        self.datasourceViewModels = datasourceViewModels
        self.selectedSource = initialSource
        self.referenceEntity = referenceEntity
    }
}
