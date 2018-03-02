//
//  IncidentListViewModel.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 19/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

open class IncidentListViewModel {

    private(set) var report: IncidentListReport?

    public init(report: IncidentListReport?) {
        self.report = report
    }

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
        incidents.forEach { incident in
            if !(report?.incidents.contains(incident) == true) {
                report?.incidents.append(incident)
            }
        }
    }
}
