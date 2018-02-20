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
        guard let report = report else { fatalError() }
        let multiple = report.incidents.count > 1
        let countString = report.incidents.count == 0 ? "No" : "\(report.incidents.count)"
        let otherString = "incident\(multiple ? "s" : "") selected"
        return "\(countString) \(otherString)"
    }

    func searchHeaderSubtitle() -> String {
        guard let report = report else { fatalError() }
        return report.incidents.map{$0.title}.joined(separator: ", ")
    }

    func sectionHeaderTitle() -> String {
        guard let count = report?.incidents.count else { return "NO INCIDENTS" }
        return "\(count) INCIDENT" + "\(count > 1 ? "S" : "")"
    }

    func add(_ incidents: [String]) {
        incidents.forEach { incident in
            if !(report?.incidents.contains(incident) == true) {
                report?.incidents.append(incident)
            }
        }
    }
}
