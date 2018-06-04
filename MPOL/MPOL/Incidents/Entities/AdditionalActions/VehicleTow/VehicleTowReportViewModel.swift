//
//  VehicleTowReportViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public class VehicleTowReportViewModel {

    public let report: VehicleTowReport

    public init(report: VehicleTowReport) {
        self.report = report
    }

    public var vehicleHold: IndexSet {
        guard let hold = report.hold else {
            return IndexSet()
        }
        return  hold ? IndexSet(integer: 0) : IndexSet(integer: 1)
    }

    public func setVehicleHold(indexSet: IndexSet) {
        // IndexSet used for radio button formItem 
        // 0 is YES
        // 1 is NO
        if indexSet.contains(0) {
            report.hold = true
        } else if indexSet.contains(1) {
            report.hold = false
        } else {
            report.hold = nil
        }
    }

}
