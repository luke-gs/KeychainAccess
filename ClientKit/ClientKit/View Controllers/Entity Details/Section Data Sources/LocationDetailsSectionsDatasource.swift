//
//  LocationDetailsSectionsDatasource.swift
//  ClientKit
//
//  Created by QHMW64 on 13/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class LocationMPOLDetailsSectionsDataSource: EntityDetailSectionsDataSource {

    public var source: EntitySource = MPOLSource.mpol
    public var entity: MPOLKitEntity
    public var detailViewControllers: [EntityDetailViewController]

    public var localizedDisplayName: String {
        return NSLocalizedString("Location", comment: "")
    }

    public func fetchModel() -> Fetchable {
        let request = LocationFetchRequest(source: source, request: EntityFetchRequest<Address>(id: entity.id))
        return EntityDetailFetch<Address>(request: request)
    }

    public init(baseEntity: Entity, delegate: EntityDetailsDelegate?) {
        self.entity = baseEntity
        self.detailViewControllers =  [
                                        EntityDetailFormViewController(viewModel: EntityAlertsViewModel()),
                                        EntityDetailFormViewController(viewModel: EntityAssociationViewModel(), delegate: delegate),
                                        EntityDetailFormViewController(viewModel: EntityEventsViewModel())
        ]
    }
}
