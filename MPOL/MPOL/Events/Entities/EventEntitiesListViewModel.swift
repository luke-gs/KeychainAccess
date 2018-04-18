//
//  EventEntitiesListViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class EventEntitiesListViewModel {
    let report: EventEntitiesListReport
    
    public init(report: EventEntitiesListReport) {
        self.report = report
    }
    
    public func tabColour() -> UIColor {
        //TODO: Implement returning colour depending on whether or not the event contains at least one entity within an incident (will presumably use the observable protocol?)
        return .red
    }
}
