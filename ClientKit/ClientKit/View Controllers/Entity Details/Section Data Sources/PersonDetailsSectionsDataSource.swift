//
//  PersonDetailsSectionsDataSource.swift
//  ClientKit
//
//  Created by RUI WANG on 21/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class PersonPSCoreDetailsSectionsDataSource: EntityDetailSectionsDataSource {

    public var source: EntitySource = MPOLSource.pscore
    public var entity: MPOLKitEntity
    public var detailViewControllers: [EntityDetailViewController]

    public var localizedDisplayName: String {
        return NSLocalizedString("Person", comment: "")
    }

    public func fetchModel() -> Fetchable {
        let request = PersonFetchRequest(source: source, request: EntityFetchRequest<Person>(id: entity.id))
        return EntityDetailFetch<Person>(request: request)
    }

    public init(baseEntity: Entity, delegate: SearchDelegate?) {
        self.entity = baseEntity
        self.detailViewControllers = [ EntityDetailFormViewController(viewModel: PersonInfoViewModel()),
                                       EntityDetailFormViewController(viewModel: EntityAlertsViewModel()),
                                       EntityDetailFormViewController(viewModel: EntityAssociationViewModel(delegate: delegate)),
                                       EntityDetailFormViewController(viewModel: EntityRetrievedEventsViewModel()),
                                       EntityDetailFormViewController(viewModel: PersonOrdersViewModel()),
                                       EntityDetailFormViewController(viewModel: PersonCriminalHistoryViewModel()),
                                       ]
    }
}

public class PersonNATDetailsSectionsDataSource: EntityDetailSectionsDataSource {

    public var source: EntitySource = MPOLSource.nat
    public var entity: MPOLKitEntity
    public var detailViewControllers: [EntityDetailViewController]

    public var localizedDisplayName: String {
        return NSLocalizedString("NAT Person", comment: "")
    }

    public func fetchModel() -> Fetchable {
        let request = PersonFetchRequest(source: source, request: EntityFetchRequest<Person>(id: entity.id))
        return EntityDetailFetch<Person>(request: request)
    }

    public init(baseEntity: Entity, delegate: SearchDelegate?) {
        self.entity = baseEntity
        self.detailViewControllers = [ EntityDetailFormViewController(viewModel: PersonInfoViewModel()),
                                       EntityDetailFormViewController(viewModel: EntityAlertsViewModel()),
                                       EntityDetailFormViewController(viewModel: EntityAssociationViewModel(delegate: delegate)),
                                       EntityDetailFormViewController(viewModel: EntityRetrievedEventsViewModel()),
                                       EntityDetailFormViewController(viewModel: PersonCriminalHistoryViewModel()),
                                       EntityDetailFormViewController(viewModel: PersonOrdersViewModel()),
                                       ]
    }

}

public class PersonRDADetailsSectionsDataSource: EntityDetailSectionsDataSource {

    public var source: EntitySource = MPOLSource.rda
    public var entity: MPOLKitEntity
    public var detailViewControllers: [EntityDetailViewController]

    public var localizedDisplayName: String {
        return NSLocalizedString("RDA Person", comment: "")
    }

    public func fetchModel() -> Fetchable {
        let request = PersonFetchRequest(source: source, request: EntityFetchRequest<Person>(id: entity.id))
        return EntityDetailFetch<Person>(request: request)
    }

    public init(baseEntity: Entity, delegate: SearchDelegate?) {
        self.entity = baseEntity
        self.detailViewControllers = [ EntityDetailFormViewController(viewModel: PersonInfoViewModel()),
                                       EntityDetailFormViewController(viewModel: EntityAlertsViewModel()),
                                       EntityDetailFormViewController(viewModel: EntityAssociationViewModel(delegate: delegate))]
    }

}
