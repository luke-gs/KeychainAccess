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
    public var detailViewControllers: [EntityDetailSectionUpdatable]

    public var localizedDisplayName: String {
        return NSLocalizedString("Vehicle", comment: "")
    }

    //    public func fetchModel(for entity: MPOLKitEntity, sources: [EntitySource]) -> Fetchable {
    //        let requests = sources.map {
    //            VehicleFetchRequest(source: $0 as! MPOLSource, request: EntityFetchRequest<Vehicle>(id: entity.id))
    //        }
    //        return EntityDetailFetch<Vehicle>(requests: requests)
    //    }

    public init(baseEntity: Entity, delegate: EntityDetailsDelegate?) {
        self.entity = baseEntity
        self.detailViewControllers =  [ VehicleInfoViewController(),
                                        EntityAlertsViewController(),
                                        EntityAssociationsViewController(delegate: delegate),
                                        VehicleOccurrencesViewController(),
                                        PersonCriminalHistoryViewController()
        ]
    }

}
public class VehicleFNCDetailsSectionsDataSource: EntityDetailSectionsDataSource {

    public var source: EntitySource = MPOLSource.fnc
    public var entity: MPOLKitEntity
    public var detailViewControllers: [EntityDetailSectionUpdatable]

    public var localizedDisplayName: String {
        return NSLocalizedString("Vehicle", comment: "")
    }

    //    public func fetchModel(for entity: MPOLKitEntity, sources: [EntitySource]) -> Fetchable {
    //        let requests = sources.map {
    //            VehicleFetchRequest(source: $0 as! MPOLSource, request: EntityFetchRequest<Vehicle>(id: entity.id))
    //        }
    //        return EntityDetailFetch<Vehicle>(requests: requests)
    //    }

    public init(baseEntity: Entity, delegate: EntityDetailsDelegate?) {
        self.entity = baseEntity
        self.detailViewControllers =  [ VehicleInfoViewController(),
                                        EntityAssociationsViewController(delegate: delegate),
                                        VehicleOccurrencesViewController(),
        ]
    }

}
