//
//  VehicleDetailsSectionsDataSource.swift
//  ClientKit
//
//  Created by RUI WANG on 21/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public class VehicleDetailsSectionsDataSource: EntityDetailSectionsDataSource {

    public var localizedDisplayName: String {
        return NSLocalizedString("Vehicle", comment: "")
    }
    
    public var detailsViewControllers: [EntityDetailCollectionViewController] = [ VehicleInfoViewController(),
                                                                                  EntityAlertsViewController(),
                                                                                  EntityAssociationsViewController(),
                                                                                  PersonCriminalHistoryViewController(),
                                                                                  VehicleOccurrencesViewController()
                                                                                  ]

    public func fetchModel(for entity: Entity, sources: [MPOLSource]) -> Fetchable {
        let requests = sources.map {
            VehicleFetchRequest(source: $0, request: EntityFetchRequest<Vehicle>(id: entity.id))
        }
        return EntityDetailsFetch<Vehicle>(requests: requests)
    }

}
