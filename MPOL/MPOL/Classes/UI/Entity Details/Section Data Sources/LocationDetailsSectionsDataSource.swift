//
//  LocationDetailsSectionsDataSource.swift
//  MPOL
//
//  Created by QHMW64 on 13/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class LocationMPOLDetailsSectionsDataSource: EntityDetailsDataSource {

    public let source: EntitySource = MPOLSource.pscore
    public let viewControllers: [UIViewController]
    public var subsequentMatches: [EntityDetailMatch] = []

    public init(delegate: SearchDelegate?) {
        self.viewControllers = [
            EntityLocationInformationViewController(viewModel: LocationInfoViewModel()),
            EntityDetailFormViewController(viewModel: EntityAlertsViewModel()),
            EntityDetailFormViewController(viewModel: EntityAssociationViewModel(delegate: delegate)),
            EntityDetailFormViewController(viewModel: EntityRetrievedEventsViewModel())
        ]
    }
}
