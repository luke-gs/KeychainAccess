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

    var eventLocation: CLPlacemark? {
        didSet {
            evaluator.updateEvaluation(for: .eventLocation)
        }
    }

    public weak var event: Event?
    public var evaluator: Evaluator = Evaluator()

    public required init(event: Event) {
        self.event = event

        evaluator.addObserver(event)
        evaluator.registerKey(.eventLocation) {
            return self.eventLocation != nil
        }
    }

    // Codable

    public required init(from: Decoder) throws {
        let container = try from.container(keyedBy: Keys.self)
        //        eventLocation = try container.decode(CLLocation.self, forKey: .eventLocation)
    }

    public func encode(to: Encoder) throws {
        var container = to.container(keyedBy: Keys.self)
        //        try container.encode(eventLocation, forKey: .eventLocation)
    }

    enum Keys: String, CodingKey {
        case eventLocation = "eventLocation"
    }

    // Evaluation

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }
}
