//
//  PersonSearchReportViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public class PersonSearchReportViewModel {

    public let report: PersonSearchReport

    public init(report: PersonSearchReport) {
        self.report = report
    }

    public var clothingRemoved: IndexSet {
        guard let clothingRemoved = report.clothingRemoved else {
            return IndexSet()
        }
        return  clothingRemoved ? IndexSet(integer: 0) : IndexSet(integer: 1)
    }

    public func setClothingRemoved(indexSet: IndexSet) {
        // IndexSet used for radio button formItem
        // 0 is YES
        // 1 is NO
        if indexSet.contains(0) {
            report.clothingRemoved = true
        } else if indexSet.contains(1) {
            report.clothingRemoved = false
        } else {
            report.clothingRemoved = nil
        }
    }
}
