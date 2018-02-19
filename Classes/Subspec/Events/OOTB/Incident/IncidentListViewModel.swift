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
}
