//
//  VehicleDetailsSectionsDataSource.swift
//  ClientKit
//
//  Created by RUI WANG on 21/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class VehicleLOCDetailsSectionsDataSource: EntityDetailSectionsDataSource {

    public var source: EntitySource = MPOLSource.pscore
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
        ]
    }
}

public class VehicleNATDetailsSectionsDataSource: EntityDetailSectionsDataSource {

    public var source: EntitySource = MPOLSource.nat
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
        ]
    }

}

public class VehicleRDADetailsSectionsDataSource: EntityDetailSectionsDataSource {

    public var source: EntitySource = MPOLSource.rda
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
        ]
    }

}
