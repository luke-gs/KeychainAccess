//
//  IncidentListViewModel.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 19/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

open class IncidentListViewModel: IncidentListViewModelType {

    public var title: String
    public var incidentList: [IncidentListDisplayable]?
    public var incidentManager: IncidentsManager
    private(set) var report: IncidentListReport?

    public required init(report: Reportable?, incidentManager: IncidentsManager = IncidentsManager.shared) {
        self.report = report as? IncidentListReport
        self.incidentManager = incidentManager
        self.title = "Incidents"

        incidentManager.add(IncidentBuilder(), for: .blank)
        incidentManager.add(StreetCheckIncidentBuilder(), for: .streetCheck)
    }

    // ViewModelType

    public func incident(for displayable: IncidentListDisplayable) -> Incident? {
        return incidentManager.incident(for: displayable.incidentId)
    }

    public func detailsViewModel(for incident: Incident) -> IncidentDetailViewModelType {
        return IncidentDetailViewModel(incident: incident, builder: IncidentScreenBuilder())
    }


    // Header

    func searchHeaderTitle() -> String {
        let string = String.localizedStringWithFormat(NSLocalizedString("%d incidents selected", comment: ""), report?.incidents.count ?? 0)
        return string
    }

    func searchHeaderSubtitle() -> String {
        guard let report = report else { fatalError() }
        return report.incidents.map{$0.title}.joined(separator: ", ")
    }

    func sectionHeaderTitle() -> String {
        let string = String.localizedStringWithFormat(NSLocalizedString("%d Incidents", comment: ""), report?.incidents.count ?? 0)
        return string.uppercased()
    }

    func add(_ incidents: [String]) {
        guard let event = self.report?.event else { return }
        for incident in incidents {
            let type = IncidentType(rawValue: incident)
            let incidentType = IncidentType.allIncidentTypes().contains(type) ? type : .blank
            guard let incident = incidentManager.create(incidentType: incidentType, in: event) else { continue }
            if !(report?.incidents.contains(where: {$0.title == incident.title}) == true) {
                report?.incidents.append(incident)
            }
        }
    }
}
