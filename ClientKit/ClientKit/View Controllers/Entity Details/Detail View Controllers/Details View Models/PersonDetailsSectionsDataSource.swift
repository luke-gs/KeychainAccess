//
//  PersonDetailsSectionsDataSource.swift
//  ClientKit
//
//  Created by RUI WANG on 21/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class PersonDetailsSectionsDataSource: EntityDetailSectionsDataSource  {

    public var localizedDisplayName: String {
        return NSLocalizedString("Person", comment: "")
    }

    public var detailViewControllers: [EntityDetailSectionUpdatable] = [ PersonInfoViewController(),
                                                                                  EntityAlertsViewController(),
                                                                                  EntityAssociationsViewController(),
                                                                                  PersonOccurrencesViewController(),
                                                                                  PersonCriminalHistoryViewController()]

    public func fetchModel(for entity: MPOLKitEntity, sources: [EntitySource]) -> Fetchable {
        let requests = sources.map {
            PersonFetchRequest(source: $0 as! MPOLSource, request: EntityFetchRequest<Person>(id: entity.id))
        }
        return EntityDetailFetch<Person>(requests: requests)
    }

    public init() {}

}
