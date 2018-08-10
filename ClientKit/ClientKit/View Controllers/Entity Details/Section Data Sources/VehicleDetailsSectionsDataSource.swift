//
//  VehicleDetailsSectionsDataSource.swift
//  ClientKit
//
//  Created by RUI WANG on 21/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class VehiclePSCoreDetailsSectionsDataSource: FancyEntityDetailsDataSource {

    public let source: EntitySource = MPOLSource.pscore
    public let viewControllers: [UIViewController]
    public var matches: [EntityDetailMatch] = [
        EntityDetailMatch(sourceToMatch: MPOLSource.nat),
        EntityDetailMatch(sourceToMatch: MPOLSource.rda)
    ]

    public init(delegate: SearchDelegate?) {
        self.viewControllers = [
            EntityDetailFormViewController(viewModel: VehicleInfoViewModel(showsRegistrationDetails: false)),
            EntityDetailFormViewController(viewModel: EntityAlertsViewModel()),
            EntityDetailFormViewController(viewModel: EntityAssociationViewModel(delegate: delegate)),
            EntityDetailFormViewController(viewModel: EntityRetrievedEventsViewModel()),

        ]
    }
}

public class VehicleNATDetailsSectionsDataSource: FancyEntityDetailsDataSource {

    public let source: EntitySource = MPOLSource.nat
    public let viewControllers: [UIViewController]
    public var matches: [EntityDetailMatch] = [
        EntityDetailMatch(sourceToMatch: MPOLSource.pscore),
        EntityDetailMatch(sourceToMatch: MPOLSource.rda)
    ]

    public init(delegate: SearchDelegate?) {
        self.viewControllers = [
            EntityDetailFormViewController(viewModel: VehicleInfoViewModel(showsRegistrationDetails: false)),
            EntityDetailFormViewController(viewModel: EntityAssociationViewModel(delegate: delegate)),
        ]
    }

}

public class VehicleRDADetailsSectionsDataSource: FancyEntityDetailsDataSource {

    public let source: EntitySource = MPOLSource.rda
    public let viewControllers: [UIViewController]
    public var matches: [EntityDetailMatch] = [
        EntityDetailMatch(sourceToMatch: MPOLSource.nat),
        EntityDetailMatch(sourceToMatch: MPOLSource.pscore)
    ]

    public init(delegate: SearchDelegate?) {
        self.viewControllers = [
            EntityDetailFormViewController(viewModel: VehicleInfoViewModel(showsRegistrationDetails: true)),
            EntityDetailFormViewController(viewModel: EntityAlertsViewModel()),
            EntityDetailFormViewController(viewModel: EntityAssociationViewModel(delegate: delegate)),
        ]
    }

}
