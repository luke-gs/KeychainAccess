//
//  AppDelegate+DataMigration.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import DemoAppKit

extension AppDelegate {

    /// Register CodableWrapper types for serialising entities
    func registerCodableWrapperTypes() {
        CodableWrapper.register(Person.self)
        CodableWrapper.register(Vehicle.self)
        CodableWrapper.register(Organisation.self)
        CodableWrapper.register(Address.self)

        // Event reportables
        CodableWrapper.register(DefaultDateTimeReport.self)
        CodableWrapper.register(DefaultEntitiesListReport.self)
        CodableWrapper.register(DefaultLocationReport.self)
        CodableWrapper.register(DefaultNotesMediaReport.self)
        CodableWrapper.register(DomesticViolenceGeneralDetailsReport.self)
        CodableWrapper.register(DomesticViolencePropertyReport.self)
        CodableWrapper.register(EventEntitiesListReport.self)
        CodableWrapper.register(EventEntityDescriptionReport.self)
        CodableWrapper.register(EventEntityDetailReport.self)
        CodableWrapper.register(EventEntityRelationshipsReport.self)
        CodableWrapper.register(IncidentListReport.self)
        CodableWrapper.register(InterceptReportGeneralDetailsReport.self)
        CodableWrapper.register(OfficerListReport.self)
        CodableWrapper.register(PersonSearchReport.self)
        CodableWrapper.register(TrafficInfringementOffencesReport.self)
        CodableWrapper.register(TrafficInfringementServiceReport.self)
        CodableWrapper.register(VehicleTowReport.self)
    }

}
