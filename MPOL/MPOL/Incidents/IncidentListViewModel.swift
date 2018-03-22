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
    public var incidentsManager: IncidentsManager
    private(set) var report: IncidentListReport
    public var incidentList: [IncidentListDisplayable] {
        return report.incidentDisplayables
    }

    public required init(report: Reportable, incidentsManager: IncidentsManager) {
        self.report = report as! IncidentListReport
        self.incidentsManager = incidentsManager
        self.title = "Incidents"

        if let objects = incidentsManager.incidentBucket.objects, !objects.isEmpty {
            self.report.incidentDisplayables = incidentsManager.displayableBucket.objects!
            self.report.incidents = incidentsManager.incidentBucket.objects!
        }
    }

    // ViewModelType

    public func incident(for displayable: IncidentListDisplayable) -> Incident? {
        return incidentsManager.incident(for: displayable.incidentId)
    }

    public func detailsViewModel(for incident: Incident) -> IncidentDetailViewModelType {
        //Switch over incident types here if you want different screen builders for each incident
        return IncidentDetailViewModel(incident: incident, builder: IncidentScreenBuilder())
    }


    // Form

    func searchHeaderTitle() -> String {
        let string = String.localizedStringWithFormat(NSLocalizedString("%d incidents selected", comment: ""), incidentList.count)
        return string
    }

    func searchHeaderSubtitle() -> String {
        return incidentList.map{$0.title}.joined(separator: ", ")
    }

    func sectionHeaderTitle() -> String {
        let string = String.localizedStringWithFormat(NSLocalizedString("%d Incidents", comment: ""), incidentList.count)
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
            guard let incident = incidentsManager.create(incidentType: incidentType, in: event) else { continue }
            if !(report.incidents.contains(where: {$0.incidentType == incident.incident.incidentType}) == true) {
                report.incidents.append(incident.incident)
                report.incidentDisplayables.append(incident.displayable)
            }
        }

        report.event?.displayable?.title = report.incidentDisplayables.map{$0.title}.joined(separator: ", ")
        report.event?.displayable?.subtitle = incidentsHeaderDefaultSubtitle
    }
}
