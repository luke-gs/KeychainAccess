//
//  PersonDetailsSectionsDataSource.swift
//  ClientKit
//
//  Created by RUI WANG on 21/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class PersonMPOLDetailsSectionsDataSource: EntityDetailSectionsDataSource {

    public var source: EntitySource = MPOLSource.mpol
    public var entity: MPOLKitEntity
    public var detailViewControllers: [EntityDetailSectionUpdatable]

    public var localizedDisplayName: String {
        return NSLocalizedString("Person", comment: "")
    }

//    public func fetchModel(for entity: MPOLKitEntity, sources: [EntitySource]) -> Fetchable {
//        let requests = sources.map {
//            PersonFetchRequest(source: $0 as! MPOLSource, request: EntityFetchRequest<Person>(id: entity.id))
//        }
//        return EntityDetailFetch<Person>(requests: requests)
//    }

    public init(baseEntity: Entity, delegate: EntityDetailsDelegate?) {
        self.entity = baseEntity
        self.detailViewControllers = [ PersonInfoViewController(),
                                       EntityAlertsViewController(),
                                       EntityAssociationsViewController(delegate: delegate),
                                       PersonOccurrencesViewController(),
                                       PersonCriminalHistoryViewController()]
    }
}

public class PersonFNCDetailsSectionsDataSource: EntityDetailSectionsDataSource {

    public var source: EntitySource = MPOLSource.fnc
    public var entity: MPOLKitEntity
    public var detailViewControllers: [EntityDetailSectionUpdatable]

    public var localizedDisplayName: String {
        return NSLocalizedString("FNC PERSON", comment: "")
    }

    //        public func fetchModel(entity: MPOLKitEntity) -> Fetchable {
    //        // Rules are defined here as needed
    //        let request = PersonFetchRequest(source: source, request: EntityFetchRequest<Person>(id: entity.id))
    //        return EntityDetailFetch<Person>(request: request)
    //        }

    public init(baseEntity: Entity, delegate: EntityDetailsDelegate?) {
        self.entity = baseEntity
        self.detailViewControllers = [ PersonInfoViewController(),
                                       EntityAlertsViewController(),
                                       EntityAssociationsViewController(delegate: delegate)]
    }
}

