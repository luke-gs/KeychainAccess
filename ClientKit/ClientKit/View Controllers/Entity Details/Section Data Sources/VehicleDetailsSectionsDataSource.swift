//
//  VehicleDetailsSectionsDataSource.swift
//  ClientKit
//
//  Created by RUI WANG on 21/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class VehicleMPOLDetailsSectionsDataSource: EntityDetailSectionsDataSource {

    public var source: EntitySource = MPOLSource.mpol
    public var entity: MPOLKitEntity
    public var detailViewControllers: [EntityDetailViewController]

    public var localizedDisplayName: String {
        return NSLocalizedString("Vehicle", comment: "")
    }

    public func fetchModel() -> Fetchable {
        let request = VehicleFetchRequest(source: source, request: EntityFetchRequest<Vehicle>(id: entity.id))
        return EntityDetailFetch<Vehicle>(request: request)
    }

    public init(baseEntity: Entity, delegate: SearchDelegate?) {
        self.entity = baseEntity
        self.detailViewControllers =  [ EntityDetailFormViewController(viewModel: VehicleInfoViewModel()),
                                        EntityDetailFormViewController(viewModel: EntityAlertsViewModel()),
                                        EntityDetailFormViewController(viewModel: EntityAssociationViewModel(delegate: delegate)),
                                        EntityDetailFormViewController(viewModel: EntityEventsViewModel())
        ]
    }
}

public class VehicleFNCDetailsSectionsDataSource: EntityDetailSectionsDataSource {

    public var source: EntitySource = MPOLSource.fnc
    public var entity: MPOLKitEntity
    public var detailViewControllers: [EntityDetailViewController]

    public var localizedDisplayName: String {
        return NSLocalizedString("Vehicle", comment: "")
    }

    public func fetchModel() -> Fetchable {
        let request = VehicleFetchRequest(source: source, request: EntityFetchRequest<Vehicle>(id: entity.id))
        return EntityDetailFetch<Vehicle>(request: request)
    }

    public init(baseEntity: Entity, delegate: SearchDelegate?) {
        self.entity = baseEntity
        self.detailViewControllers =  [ EntityDetailFormViewController(viewModel: VehicleInfoViewModel()),
                                        EntityDetailFormViewController(viewModel: EntityAssociationViewModel(delegate: delegate)),
                                        EntityDetailFormViewController(viewModel: EntityEventsViewModel()),
        ]
    }

}
