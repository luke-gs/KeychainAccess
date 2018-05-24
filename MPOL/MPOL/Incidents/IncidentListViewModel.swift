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
        return report.incidents.map { $0.displayable! }
    }

    public var primaryIncident: IncidentListDisplayable? {
        return incidentList.first
    }

    public var additionalIncidents: [IncidentListDisplayable]? {
        return Array(incidentList.dropFirst())
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
        case .domesticViolence:
            return IncidentDetailViewModel(incident: incident, builder: DomesticViolenceScreenBuilder())
        default:
            fatalError("IncidentListViewModel Error: incident type is not a valid InccidentType")
        }
    }

    func subtitle(for displayable: IncidentListDisplayable) -> String {
        let eval = incident(for: displayable)?.evaluator.isComplete ?? false
        return eval ? "Complete" : "In Progress"
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
        return incidentList.map { $0.title }.joined(separator: ", ")
    }

    func additionalIndicentsSectionHeaderTitle() -> String {
        let count = additionalIncidents?.count ?? 0

        // TODO: Change this to use NSLocalizedString to handle plurals
        return (additionalIncidents?.isEmpty)! ? "No Additional Incidents" : ("\(count) Additional Incident" + (count > 1 ? "s" : ""))
    }

    // Utility

    func removeIncident(_ incident: Incident) {
        report.event?.entityManager.removeAllRelationships(for: incident)
        report.incidents = report.incidents.filter({$0 != incident})
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

    func changePrimaryIncident(_ index: Int) {
        let newPrimaryIncident = report.incidents.remove(at: index)
        report.incidents.insert(newPrimaryIncident, at: 0)
    }

    // Incident action helpers

    func actionDefinitionStructForType(type: IncidentActionType, context: IncidentListViewController) -> IncidentActionDefiniton {
        switch type {
        case .add:
            return AddIncidentDefinition(for: context)
        case .choosePrimary:
            return ChoosePrimaryIncidentDefinition(for: context)
        case .deletePrimary:
            return DeletePrimaryIncidentDefinition(for: context)
        }
    }
}
