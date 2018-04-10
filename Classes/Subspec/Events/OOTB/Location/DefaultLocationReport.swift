//
//  DefaultLocationReport.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MapKit

fileprivate extension EvaluatorKey {
    static let eventLocation = EvaluatorKey(rawValue: "eventLocation")
}

open class DefaultLocationReport: Reportable {

    public var eventLocation: EventLocation? {
        didSet {
            evaluator.updateEvaluation(for: .eventLocation)
        }
    }

    public var evaluator: Evaluator = Evaluator()
    public weak var event: Event?
    public weak var incident: Incident?

    public required init(event: Event) {
        self.event = event

        evaluator.addObserver(event)
        evaluator.registerKey(.eventLocation) {
            return self.eventLocation != nil
        }
    }

    // Codable

    public static var supportsSecureCoding: Bool = true
    private enum Coding: String {
        case eventLocation
    }


    public required init?(coder aDecoder: NSCoder) {
        eventLocation = aDecoder.decodeObject(of: EventLocation.self, forKey: Coding.eventLocation.rawValue)
    }


    public func encode(with aCoder: NSCoder) {
        aCoder.encode(eventLocation, forKey: Coding.eventLocation.rawValue)
    }

    // Evaluation

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }
}

