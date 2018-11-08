//
//  DefaultReportable.swift
//  DemoAppKit
//
//  Created by Trent Fitzgibbon on 2/11/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Default base class for a Reportable
open class DefaultReportable: Reportable {

    /// Reference back to the grandparent event
    open var weakEvent: Weak<Event> {
        didSet {
            if let event = event, oldValue.object == nil {
                configure(with: event)
            }
        }
    }

    /// Reference back to the parent incident
    open var weakIncident: Weak<Incident> {
        didSet {
            if let incident = incident, oldValue.object == nil {
                configure(with: incident)
            }
        }
    }

    /// Evaluator for this report
    open var evaluator: Evaluator = Evaluator()

    // Empty init
    public init() {
        weakEvent = Weak(nil)
        weakIncident = Weak(nil)
    }

    // Default init taking event and incident
    public init(event: Event, incident: Incident) {
        weakEvent = Weak(event)
        weakIncident = Weak(incident)

        configure(with: event)
        configure(with: incident)
    }

    /// Perform any configuration now that we have an event
    open func configure(with event: Event) {
        evaluator.addObserver(event)
    }

    /// Perform any configuration now that we have an incident
    open func configure(with incident: Incident) {
        evaluator.addObserver(incident)
    }

    // MARK: - Codable

    public required init(from decoder: Decoder) throws {
        /// Set event and incident to nil initially, until parent passes it to us during it's decode
        weakEvent = Weak(nil)
        weakIncident = Weak(nil)
    }

    open func encode(to encoder: Encoder) throws {
        // Nothing by default
    }

    // Evaluation

    open func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        // Nothing by default
    }

}
