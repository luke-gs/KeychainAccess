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
        incidents.forEach { string in
            let incident = incidentManager.create(incidentType: .blank, in: (self.report?.event!)!)
//            if !(report?.incidents.contains(incident) == true) {
//                report?.incidents.append(incident)
//            }
        }
    }
}
