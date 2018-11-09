//
//  PersonSearchReport.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//
import PublicSafetyKit

fileprivate extension EvaluatorKey {
    static let hasRequiredData = EvaluatorKey("hasRequiredData")
}

public class PersonSearchReport: DefaultActionReportable {

    public var searchType: String?
    public var detainedStart: Date? {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var detainedEnd: Date?
    public var searchStart: Date? {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var searchEnd: Date?
    public var location: EventLocation? {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var officers = [Officer]() {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var legalPower: String? {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var searchReason: String? {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var outcome: String? {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var clothingRemoved: Bool? {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var remarks: String?

    // MARK: - DefaultActionReportable

    public override init(incident: Incident?, additionalAction: AdditionalAction) {
        super.init(incident: incident, additionalAction: additionalAction)
    }

    public override func configure(with event: Event) {
        super.configure(with: event)

        evaluator.registerKey(.hasRequiredData) { [weak self] in
            guard let `self` = self else { return false }
            return self.detainedStart != nil && self.searchStart != nil
                && self.location != nil && !self.officers.isEmpty
                && self.legalPower != nil && self.searchReason != nil
                && self.outcome != nil && self.clothingRemoved != nil
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case clothingRemoved
        case detainedEnd
        case detainedStart
        case legalPower
        case location
        case officers
        case outcome
        case remarks
        case searchEnd
        case searchReason
        case searchStart
        case searchType
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        clothingRemoved = try container.decodeIfPresent(Bool.self, forKey: .clothingRemoved)
        detainedEnd = try container.decodeIfPresent(Date.self, forKey: .detainedEnd)
        detainedStart = try container.decodeIfPresent(Date.self, forKey: .detainedStart)
        legalPower = try container.decodeIfPresent(String.self, forKey: .legalPower)
        location = try container.decodeIfPresent(EventLocation.self, forKey: .location)
        officers = try container.decode([Officer].self, forKey: .officers)
        outcome = try container.decodeIfPresent(String.self, forKey: .outcome)
        remarks = try container.decodeIfPresent(String.self, forKey: .remarks)
        searchEnd = try container.decodeIfPresent(Date.self, forKey: .searchEnd)
        searchReason = try container.decodeIfPresent(String.self, forKey: .searchReason)
        searchStart = try container.decodeIfPresent(Date.self, forKey: .searchStart)
        searchType = try container.decodeIfPresent(String.self, forKey: .searchType)

        try super.init(from: decoder)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(clothingRemoved, forKey: CodingKeys.clothingRemoved)
        try container.encode(detainedEnd, forKey: CodingKeys.detainedEnd)
        try container.encode(detainedStart, forKey: CodingKeys.detainedStart)
        try container.encode(legalPower, forKey: CodingKeys.legalPower)
        try container.encode(location, forKey: CodingKeys.location)
        try container.encode(officers, forKey: CodingKeys.officers)
        try container.encode(outcome, forKey: CodingKeys.outcome)
        try container.encode(remarks, forKey: CodingKeys.remarks)
        try container.encode(searchEnd, forKey: CodingKeys.searchEnd)
        try container.encode(searchReason, forKey: CodingKeys.searchReason)
        try container.encode(searchStart, forKey: CodingKeys.searchStart)
        try container.encode(searchType, forKey: CodingKeys.searchType)
    }

}

extension AdditionalActionType {
    public static let personSearch = AdditionalActionType(rawValue: "Person Search Report")
}
