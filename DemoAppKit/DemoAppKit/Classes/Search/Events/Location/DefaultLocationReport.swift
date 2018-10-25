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
    public let weakEvent: Weak<Event>

    public var eventLocation: EventLocation? {
        didSet {
            evaluator.updateEvaluation(for: .eventLocation)
        }
    }

    public var evaluator: Evaluator = Evaluator()

    public required init(event: Event) {
        self.weakEvent = Weak(event)

        evaluator.addObserver(event)
        evaluator.registerKey(.eventLocation) { [weak self] in
            guard let `self` = self else { return false }
            return self.eventLocation != nil
        }
    }

    // Codable

    public static var supportsSecureCoding: Bool = true
    private enum Coding: String {
        case eventLocation
        case event
    }

    public required init?(coder aDecoder: NSCoder) {
        eventLocation = aDecoder.decodeObject(of: EventLocation.self, forKey: Coding.eventLocation.rawValue)
        weakEvent = aDecoder.decodeWeakObject(forKey: Coding.event.rawValue)
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(eventLocation, forKey: Coding.eventLocation.rawValue)
        aCoder.encodeWeakObject(weakObject: weakEvent, forKey: Coding.event.rawValue)
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
