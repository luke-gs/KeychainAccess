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
    public var incidentManager: IncidentsManager
    private(set) var report: IncidentListReport
    public var incidentList: [IncidentListDisplayable]? {
        return report.incidentDisplayables
    }

    public required init(report: Reportable, incidentManager: IncidentsManager = IncidentsManager.shared) {
        self.report = report as! IncidentListReport
        self.incidentManager = incidentManager
        self.title = "Incidents"

        // Add IncidentBuilders here
        incidentManager.add(InfringementIncidentBuilder(), for: .infringementNotice)
        incidentManager.add(StreetCheckIncidentBuilder(), for: .streetCheck)
    }

    // ViewModelType

    public func incident(for displayable: IncidentListDisplayable) -> Incident? {
        return incidentManager.incident(for: displayable.incidentId)
    }

    public func detailsViewModel(for incident: Incident) -> IncidentDetailViewModelType {
        //Switch over incident types here if you want different screen builders for each incident
        return IncidentDetailViewModel(incident: incident, builder: IncidentScreenBuilder())
    }


    // Form

    func searchHeaderTitle() -> String {
        let string = String.localizedStringWithFormat(NSLocalizedString("%d incidents selected", comment: ""), report.incidents.count)
        return string
    }

    func searchHeaderSubtitle() -> String {
        return report.incidentDisplayables.map{$0.title}.joined(separator: ", ")
    }

    func sectionHeaderTitle() -> String {
        let string = String.localizedStringWithFormat(NSLocalizedString("%d Incidents", comment: ""), report.incidents.count)
        return string.uppercased()
    }
    
    func image(for displayable: IncidentListDisplayable) -> UIImage {
        let eval = incident(for: displayable)?.evaluator.isComplete ?? false
        guard let image = AssetManager.shared.image(forKey: AssetManager.ImageKey.document)?
            .withCircleBackground(tintColor: .black,
                                  circleColor: eval ? .midGreen : .red,
                                  style: .auto(padding: CGSize(width: 24, height: 24), shrinkImage: false)) else { fatalError() }
        return image
    }

    // Utility

    func removeIncident(at indexPath: IndexPath) {
        report.incidents.remove(at: indexPath.item)
        report.incidentDisplayables.remove(at: indexPath.item)
        report.event?.displayable?.title = report.incidentDisplayables.count > 0
            ? report.incidentDisplayables.map{$0.title}.joined(separator: ", ")
            : incidentsHeaderDefaultTitle
        report.event?.displayable?.subtitle = incidentsHeaderDefaultSubtitle
    }

    func add(_ incidents: [String]) {
        guard let event = self.report.event else { return }
        for incident in incidents {
            let type = IncidentType(rawValue: incident)
            let incidentType = IncidentType.allIncidentTypes().contains(type) ? type : .blank
            guard let incident = incidentManager.create(incidentType: incidentType, in: event) else { continue }
            if !(report.incidents.contains(where: {$0.incidentType == incident.incident.incidentType}) == true) {
                report.incidents.append(incident.incident)
                report.incidentDisplayables.append(incident.displayable)
            }
        }

        report.event?.displayable?.title = report.incidentDisplayables.map{$0.title}.joined(separator: ", ")
        report.event?.displayable?.subtitle = incidentsHeaderDefaultSubtitle
    }
}
