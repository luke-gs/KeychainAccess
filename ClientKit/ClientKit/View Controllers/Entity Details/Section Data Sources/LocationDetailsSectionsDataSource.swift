//
//  LocationDetailsSectionsDatasource.swift
//  ClientKit
//
//  Created by QHMW64 on 13/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class LocationMPOLDetailsSectionsDataSource: FancyEntityDetailsDataSource {

    public let source: EntitySource = MPOLSource.pscore
    public let viewControllers: [UIViewController]
    public var matches: [EntityDetailMatch] = []

    public init(delegate: SearchDelegate?) {
        self.viewControllers = [
            EntityLocationInformationViewController(viewModel: LocationInfoViewModel()),
            EntityDetailFormViewController(viewModel: EntityAlertsViewModel()),
            EntityDetailFormViewController(viewModel: EntityAssociationViewModel(delegate: delegate)),
            EntityDetailFormViewController(viewModel: EntityRetrievedEventsViewModel())
        ]
    }
}
