//
//  DefaultLocationReport.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

fileprivate extension EvaluatorKey {
    static let eventLocation = EvaluatorKey(rawValue: "eventLocation")
}

open class DefaultLocationReport: DefaultEventReportable {

    public var eventLocations: [EventLocation] = [] {
        didSet {
            evaluator.updateEvaluation(for: .eventLocation)
        }
    }

    public override init(event: Event) {
        super.init(event: event)
        commonInit()
    }

    private func commonInit() {
        evaluator.registerKey(.eventLocation) { [weak self] in
            guard let `self` = self else { return false }
            return !self.eventLocations.isEmpty
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case eventLocations
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        eventLocations = try container.decodeIfPresent([EventLocation].self, forKey: .eventLocations) ?? []

        try super.init(from: decoder)
        commonInit()
    }

    open override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if eventLocations.count > 0 {
            try container.encodeIfPresent(eventLocations, forKey: .eventLocations)
        }

        try super.encode(to: encoder)
    }
}

extension DefaultLocationReport: Summarisable {

    public var formItems: [FormItem] {
        var items = [FormItem]()
        items.append(LargeTextHeaderFormItem(text: "Locations"))

        eventLocations.forEach { location in
            items.append(RowDetailFormItem(title: "Event Location", detail: location.addressString ?? "Required"))
        }
        return items
    }
}
