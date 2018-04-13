//
//  DefaultEventDateTimeViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public class DefaultDateTimeViewModel {

    weak var report: DefaultDateTimeReport!

    public init(report: DefaultDateTimeReport) {
        self.report = report
    }

    public func tabColour() -> UIColor {
        return report.evaluator.isComplete ? .midGreen : .red
    }

    public func reportedOnDateTimeChanged(_ date: Date?) {
        report.reportedOnDateTime = date
    }

    public func tookPlaceFromStartDateTimeChanged(_ date: Date?) {
        report.tookPlaceFromStartDateTime = date
    }

    public func tookPlaceFromEndDateTimeChanged(_ date: Date?) {
        report.tookPlaceFromEndDateTime = date
    }

    func adjustEndTime(for date: Date?, in formItem: DateFormItem) {
        formItem.minimumDate = date
        guard date != report.tookPlaceFromStartDateTime else { return }
        guard let startDate = date, let endDate = report.tookPlaceFromEndDateTime else { return }
        if startDate > endDate {
            report?.tookPlaceFromEndDateTime = nil
            formItem.selectedValue = nil
            formItem.reloadItem()
        }
    }
}

