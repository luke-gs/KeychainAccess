//
//  VehicleDetailsSectionsDataSource.swift
//  ClientKit
//
//  Created by RUI WANG on 21/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class VehicleDetailsSectionsDataSource: EntityDetailSectionsDataSource {

    public var initialSource: EntitySource

    public var sources: [EntitySource] {
        return [MPOLSource.mpol, MPOLSource.fnc]
    }

    public var baseEntity: MPOLKitEntity

    public var localizedDisplayName: String {
        return NSLocalizedString("Vehicle", comment: "")
    }
    
    public var detailViewControllers: [EntityDetailSectionUpdatable]

    public func fetchModel(for entity: MPOLKitEntity, sources: [EntitySource]) -> Fetchable {
        let requests = sources.map {
            VehicleFetchRequest(source: $0 as! MPOLSource, request: EntityFetchRequest<Vehicle>(id: entity.id))
        }
        return EntityDetailFetch<Vehicle>(requests: requests)
    }

    public init(baseEntity: Entity, delegate: EntityDetailsDelegate?) {
        self.baseEntity = baseEntity
        self.initialSource = baseEntity.source!

        self.detailViewControllers =  [ VehicleInfoViewController(),
                                        EntityAlertsViewController(),
                                        EntityAssociationsViewController(delegate: delegate),
                                        PersonCriminalHistoryViewController(),
                                        VehicleOccurrencesViewController()]
    }

}
