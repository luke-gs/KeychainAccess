//
//  EventOfficerListViewModel.swift
//  MPOL
//
//  Created by QHMW64 on 9/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public protocol EventOfficerListViewModelDelegate: class {
    func officerListDidUpdate()
    func didSelectOfficer(officer: Officer)
}

public class EventOfficerListViewModel {

    /// This variable matches the 'reportingOfficer' officer involvement manifest item
    public static let reportingOfficerInvolvement = NSLocalizedString("Reporting officer", comment: "")

    weak var delegate: EventOfficerListViewModelDelegate?
    public let report: OfficerListReport

    var officerDisplayables: [OfficerSummaryDisplayable] = [] {
        didSet {
            delegate?.officerListDidUpdate()
        }
    }

    init(report: OfficerListReport) {
        self.report = report
        officerDisplayables = report.officers.map { OfficerSummaryDisplayable($0) }
    }

    var tabColors: (defaultColor: UIColor, selectedColor: UIColor) {
        if report.evaluator.isComplete {
            return (defaultColor: .midGreen, selectedColor: .midGreen)
        } else {
            return (defaultColor: .secondaryGray, selectedColor: .tabBarWhite)
        }
    }

    public var title: String? {
        return "Officers"
    }

    public var officerInvolvementOptions: [Pickable] {
        return Manifest.shared.entries(for: .eventOfficerInvolvement).pickableList()
    }

    public func officer(at indexPath: IndexPath) -> Officer {
        return report.officers[indexPath.row]
    }

    public var header: String? {
        return String.localizedStringWithFormat(NSLocalizedString("%d Officers", comment: ""), report.officers.count)
    }

    public func displayable(for officer: Officer) -> OfficerSummaryDisplayable? {
        if let index = officerDisplayables.index(where: { $0.officer == officer }) {
            return officerDisplayables[index]
        }
        return nil
    }

    public func containsReportingOfficer() -> Bool {
        let hasReportingOfficer = report.officers.contains(where: {
            $0.involvements.contains(where: {
                $0.caseInsensitiveCompare(EventOfficerListViewModel.reportingOfficerInvolvement) == .orderedSame
            })
        })
        return hasReportingOfficer
    }

    // MARK: - Addition/Deletion

    public func add(officer: Officer) {
        guard report.officers.index(where: {$0 == officer}) == nil else { return }
        officerDisplayables.append(OfficerSummaryDisplayable(officer))
        report.officers.append(officer)
    }

    public func add(_ involvements: [String], to officer: Officer) {
        let reportingOfficerInvolvement = EventOfficerListViewModel.reportingOfficerInvolvement

        // check if we have a new 'reporting officer'
        // if so remove 'reporting' involvement from previous 'reporting officer'
        if involvements.contains(reportingOfficerInvolvement) {
            let reportingOfficer = self.officerDisplayables.map {$0.officer}
                .filter {$0.involvements.contains(reportingOfficerInvolvement)}.first
            reportingOfficer?.involvements = reportingOfficer?.involvements.filter {$0 != reportingOfficerInvolvement} ?? []
        }

        officer.involvements = involvements
        report.evaluator.updateEvaluation(for: .officers)
    }

    func remove(_ officer: Officer) {
        if let index = report.officers.firstIndex(of: officer) {
            removeOfficer(at: IndexPath(row: index, section: 0))
        }
    }

    func removeOfficer(at indexPath: IndexPath) {
        officerDisplayables.remove(at: indexPath.row)
        report.officers.remove(at: indexPath.row)
    }
}
