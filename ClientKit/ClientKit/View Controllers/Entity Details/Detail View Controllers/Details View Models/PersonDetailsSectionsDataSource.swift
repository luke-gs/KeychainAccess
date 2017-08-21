//
//  PersonDetailsSectionsDataSource.swift
//  ClientKit
//
//  Created by RUI WANG on 21/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public class PersonDetailsSectionsDataSource: EntityDetailSectionsDataSource  {
    
    public var localizedDisplayName: String {
        return NSLocalizedString("Person", comment: "")
    }
    
    public var detailsViewControllers: [EntityDetailCollectionViewController] = [ PersonInfoViewController(),
                                                                                  EntityAlertsViewController(),
                                                                                  EntityAssociationsViewController(),
                                                                                  PersonOccurrencesViewController(),
                                                                                  PersonCriminalHistoryViewController()]
    
    public func fetchModel(for entity: Entity, sources: [MPOLSource]) -> Fetchable {
        let requests = sources.map {
            PersonFetchRequest(source: $0, request: EntityFetchRequest<Person>(id: entity.id))
        }
        return EntityDetailsFetch<Person>(requests: requests)
    }
}
