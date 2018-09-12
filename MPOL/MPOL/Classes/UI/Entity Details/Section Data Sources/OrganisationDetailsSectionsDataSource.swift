//
//  OrganisationDetailsSectionsDataSource.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class OrganisationPSCoreDetailsSectionsDataSource: EntityDetailsDataSource {
    
    public let source: EntitySource = MPOLSource.pscore
    public let viewControllers: [UIViewController]
    public var subsequentMatches: [EntityDetailMatch] = [
        EntityDetailMatch(sourceToMatch: MPOLSource.nat),
        EntityDetailMatch(sourceToMatch: MPOLSource.rda)
    ]
    
    public init(delegate: SearchDelegate?) {
        self.viewControllers = [
            EntityLocationInformationViewController(viewModel: OrganisationInfoViewModel()),
            EntityDetailFormViewController(viewModel: EntityAlertsViewModel()),
            EntityDetailFormViewController(viewModel: EntityAssociationViewModel(delegate: delegate)),
            EntityDetailFormViewController(viewModel: EntityRetrievedEventsViewModel())
        ]
    }
}

public class OrganisationNATDetailsSectionsDataSource: EntityDetailsDataSource {
    
    public var source: EntitySource = MPOLSource.nat
    public let viewControllers: [UIViewController]
    public var subsequentMatches: [EntityDetailMatch] = [
        EntityDetailMatch(sourceToMatch: MPOLSource.pscore),
        EntityDetailMatch(sourceToMatch: MPOLSource.rda)
    ]
    
    public init(delegate: SearchDelegate?) {
        self.viewControllers = [
            EntityLocationInformationViewController(viewModel: OrganisationInfoViewModel()),
            EntityDetailFormViewController(viewModel: EntityAlertsViewModel()),
            EntityDetailFormViewController(viewModel: EntityAssociationViewModel(delegate: delegate)),
            EntityDetailFormViewController(viewModel: EntityRetrievedEventsViewModel())
        ]
    }
}

public class OrganisationRDADetailsSectionsDataSource: EntityDetailsDataSource {
    
    public var source: EntitySource = MPOLSource.rda
    public let viewControllers: [UIViewController]
    public var subsequentMatches: [EntityDetailMatch] = [
        EntityDetailMatch(sourceToMatch: MPOLSource.pscore),
        EntityDetailMatch(sourceToMatch: MPOLSource.nat)
    ]
    
    public init(delegate: SearchDelegate?) {
        self.viewControllers = [
            EntityLocationInformationViewController(viewModel: OrganisationInfoViewModel()),
            EntityDetailFormViewController(viewModel: EntityAlertsViewModel()),
            EntityDetailFormViewController(viewModel: EntityAssociationViewModel(delegate: delegate))
        ]
    }
}
