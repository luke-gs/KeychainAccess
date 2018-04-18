//
//  EventEntitiesListReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit
import Foundation

public class EventEntitiesListReport : Reportable {
    public var event: Event?
    
    public var incident: Incident?
    
    public static var supportsSecureCoding: Bool {
        return true
    }
    
    public init(event: Event) {
        self.event = event
    }
    
    //need to implement
    public let evaluator: Evaluator = Evaluator()
    
    //need to implement
    public func encode(with aCoder: NSCoder) {
        
    }
    
    //need to implement
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    //need to implement
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        
    }
    
    
}
