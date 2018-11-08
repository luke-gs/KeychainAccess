//
//  DefaultEventReportable.swift
//  DemoAppKit
//
//  Created by Trent Fitzgibbon on 2/11/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Default base class for an EventReportable
open class DefaultEventReportable: EventReportable {

    /// Reference back to the parent event
    open var weakEvent: Weak<Event> {
        didSet {
            if let event = event, oldValue.object == nil {
                configure(with: event)
            }
        }
    }

    /// Evaluator for this report
    open var evaluator: Evaluator = Evaluator()

    // Default init taking event
    public init(event: Event) {
        self.weakEvent = Weak(event)
        configure(with: event)
    }

    /// Perform any configuration now that we have an event
    open func configure(with event: Event) {
        evaluator.addObserver(event)
    }

    // MARK: - Codable

    public required init(from decoder: Decoder) throws {
        /// Set event to nil initially, until parent passes it to us during it's decode
        self.weakEvent = Weak(nil)
    }

    open func encode(to encoder: Encoder) throws {
        // Nothing by default
    }

    // Evaluation

    open func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        // Nothing by default
    }

}
