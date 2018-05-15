//
//  IncidentListViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

open class IncidentListViewModel: IncidentListViewModelType {

    public var title: String
    public var incidentsManager: IncidentsManager
    private(set) var report: IncidentListReport
    public var incidentList: [IncidentListDisplayable] {
        return report.incidents.map{ $0.displayable! }
    }

    public required init(report: Reportable, incidentsManager: IncidentsManager) {
        self.report = report as! IncidentListReport
        self.incidentsManager = incidentsManager
        self.title = "Incidents"

        if let objects = incidentsManager.incidentBucket.objects, !objects.isEmpty {
            self.report.incidents = incidentsManager.incidentBucket.objects!
        }
    }

    var tabColors: (defaultColor: UIColor, selectedColor: UIColor) {
        if report.evaluator.isComplete {
            return (defaultColor: .midGreen, selectedColor: .midGreen)
        } else {
            return (defaultColor: .secondaryGray, selectedColor: .tabBarWhite)
        }
    }

    // ViewModelType

    public func incident(for displayable: IncidentListDisplayable) -> Incident? {
        return incidentsManager.incident(for: displayable.incidentId)
    }

    public func detailsViewModel(for incident: Incident) -> IncidentDetailViewModelType {
        // Switch over incident types here if you want different screen builders for each incident
        switch incident.incidentType {

        case .trafficInfringement:
            return IncidentDetailViewModel(incident: incident, builder: TrafficInfringementScreenBuilder())
        case .interceptReport:
            return IncidentDetailViewModel(incident: incident, builder: InterceptReportScreenBuilder())
        default:
            fatalError("IncidentListViewModel Error: incident type is not a valid InccidentType")
        }
    }

    func subtitle(for displayable: IncidentListDisplayable) -> String {
        let eval = incident(for: displayable)?.evaluator.isComplete ?? false
        return eval ? "COMPLETE" : "IN PROGRESS"
    }

    func image(for displayable: IncidentListDisplayable) -> UIImage {
        let eval = incident(for: displayable)?.evaluator.isComplete ?? false
        guard let image = AssetManager.shared.image(forKey: AssetManager.ImageKey.documentFilled)?
            .withCircleBackground(tintColor: .black,
                                  circleColor: eval ? .midGreen : .disabledGray,
                                  style: .auto(padding: CGSize(width: 24, height: 24), shrinkImage: false)) else { fatalError() }
        return image
    }

    // Form

    func searchHeaderTitle() -> String {
        let string = String.localizedStringWithFormat(NSLocalizedString("%d incidents selected", comment: ""), incidentList.count)
        return string
    }

    func searchHeaderSubtitle() -> String {
        return incidentList.map{ $0.title }.joined(separator: ", ")
    }

    func sectionHeaderTitle() -> String {
        let string = String.localizedStringWithFormat(NSLocalizedString("%d Incidents", comment: ""), incidentList.count)
        return string.uppercased()
    }

    // Utility

    func removeIncident(at indexPath: IndexPath) {
        report.incidents.remove(at: indexPath.item)

        // TODO: create entity manager on event that will handle the links between entities and incidents
        // TODO: use event.entity manager to remove entities linked to this event
        report.event?.entityBucket.removeAll()
    }

    func add(_ incidents: [String]) {
        guard let event = self.report.event else { return }
        for incident in incidents {
            let type = IncidentType(rawValue: incident)
            let incidentType = IncidentType.allIncidentTypes().contains(type) ? type : .blank
            guard let incident = incidentsManager.create(incidentType: incidentType, in: event) else { continue }
            if !(report.incidents.contains(where: {$0.incidentType == incident.incidentType}) == true) {
                report.incidents.append(incident)
            }
        }
    }
}
