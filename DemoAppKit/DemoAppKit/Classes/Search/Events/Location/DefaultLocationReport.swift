//
//  DefaultLocationReport.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MapKit

fileprivate extension EvaluatorKey {
    static let eventLocation = EvaluatorKey(rawValue: "eventLocation")
}

open class DefaultLocationReport: EventReportable {
    public var weakEvent: Weak<Event>

    public var eventLocation: EventLocation? {
        didSet {
            evaluator.updateEvaluation(for: .eventLocation)
        }
    }

    public var evaluator: Evaluator = Evaluator()

    public required init(event: Event) {
        self.weakEvent = Weak(event)
        commonInit()
    }

    private func commonInit() {
        if let event = self.event {
            evaluator.addObserver(event)
        }
        evaluator.registerKey(.eventLocation) { [weak self] in
            guard let `self` = self else { return false }
            return self.eventLocation != nil
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case eventLocation
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        eventLocation = try container.decodeIfPresent(EventLocation.self, forKey: .eventLocation)
        weakEvent = Weak<Event>(nil)
        commonInit()
    }

    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(eventLocation, forKey: CodingKeys.eventLocation)
    }

    // Evaluation
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }
}

extension DefaultLocationReport: Summarisable {

    public var formItems: [FormItem] {
        var items = [FormItem]()
        items.append(LargeTextHeaderFormItem(text: "Locations"))
        items.append(RowDetailFormItem(title: "Event Location", detail: eventLocation?.addressString ?? "Required").styleIdentifier(eventLocation == nil ? DemoAppKitStyler.summaryRequiredStyle : nil))
        return items
    }
}
