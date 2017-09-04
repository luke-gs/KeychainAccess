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

    public var localizedDisplayName: String {
        return NSLocalizedString("Vehicle", comment: "")
    }
    
    public var detailViewControllers: [EntityDetailSectionUpdatable] = [ VehicleInfoViewController(),
                                                                                  EntityAlertsViewController(),
                                                                                  EntityAssociationsViewController(),
                                                                                  PersonCriminalHistoryViewController()]

    public func fetchModel(for entity: MPOLKitEntity, sources: [EntitySource]) -> Fetchable {
        let requests = sources.map {
            VehicleFetchRequest(source: $0 as! MPOLSource, request: EntityFetchRequest<Vehicle>(id: entity.id))
        }
        return EntityDetailFetch<Vehicle>(requests: requests)
    }

}
