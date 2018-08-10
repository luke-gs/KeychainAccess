//
//  PersonDetailsSectionsDataSource.swift
//  ClientKit
//
//  Created by RUI WANG on 21/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class PersonPSCoreDetailsSectionsDataSource: FancyEntityDetailsDataSource {

    public let source: EntitySource = MPOLSource.pscore
    public let viewControllers: [UIViewController]
    public var matches: [EntityDetailMatch] = [
        EntityDetailMatch(sourceToMatch: MPOLSource.nat),
        EntityDetailMatch(sourceToMatch: MPOLSource.rda)
    ]

    public init(delegate: SearchDelegate?) {
        self.viewControllers = [
            EntityDetailFormViewController(viewModel: PersonInfoViewModel(showingLicenceDetails: false)),
            EntityDetailFormViewController(viewModel: EntityAlertsViewModel()),
            EntityDetailFormViewController(viewModel: EntityAssociationViewModel(delegate: delegate)),
            EntityDetailFormViewController(viewModel: EntityRetrievedEventsViewModel()),
            EntityDetailFormViewController(viewModel: PersonOrdersViewModel()),
            EntityDetailFormViewController(viewModel: PersonCriminalHistoryViewModel()),
        ]
    }
}

public class PersonNATDetailsSectionsDataSource: FancyEntityDetailsDataSource {

    public var source: EntitySource = MPOLSource.nat
    public let viewControllers: [UIViewController]
    public var matches: [EntityDetailMatch] = [
        EntityDetailMatch(sourceToMatch: MPOLSource.pscore),
        EntityDetailMatch(sourceToMatch: MPOLSource.rda)
    ]

    public init(delegate: SearchDelegate?) {
        self.viewControllers = [
            EntityDetailFormViewController(viewModel: PersonInfoViewModel(showingLicenceDetails: false)),
            EntityDetailFormViewController(viewModel: EntityAlertsViewModel()),
            EntityDetailFormViewController(viewModel: EntityAssociationViewModel(delegate: delegate)),
            EntityDetailFormViewController(viewModel: EntityRetrievedEventsViewModel()),
            EntityDetailFormViewController(viewModel: PersonOrdersViewModel()),
            EntityDetailFormViewController(viewModel: PersonCriminalHistoryViewModel())
        ]
    }

}

public class PersonRDADetailsSectionsDataSource: FancyEntityDetailsDataSource {

    public var source: EntitySource = MPOLSource.rda
    public let viewControllers: [UIViewController]
    public var matches: [EntityDetailMatch] = [
        EntityDetailMatch(sourceToMatch: MPOLSource.pscore),
        EntityDetailMatch(sourceToMatch: MPOLSource.nat)
    ]

    public init(delegate: SearchDelegate?) {
        self.viewControllers = [
            EntityDetailFormViewController(viewModel: PersonInfoViewModel(showingLicenceDetails: true)),
            EntityDetailFormViewController(viewModel: EntityAlertsViewModel()),
            EntityDetailFormViewController(viewModel: EntityAssociationViewModel(delegate: delegate)),
            PersonTrafficHistoryViewController(viewModel: PersonTrafficHistoryViewModel())
        ]
    }

}
