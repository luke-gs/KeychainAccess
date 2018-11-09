//
//  VehicleTowReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

fileprivate extension EvaluatorKey {
    static let hasRequiredData = EvaluatorKey("hasRequiredData")
}

public class VehicleTowReport: DefaultActionReportable, MediaContainer {

    public var location: EventLocation? {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var towReason: String?
    public var authorisingOfficer: Officer?
    public var notifyingOfficer: Officer?
    public var date: Date?
    public var hold: Bool? {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var holdReason: String?
    public var holdRemarks: String?
    public var media: [MediaAsset] = []

    // MARK: - DefaultActionReportable

    public override init(incident: Incident?, additionalAction: AdditionalAction) {
        super.init(incident: incident, additionalAction: additionalAction)
    }

    public override func configure(with event: Event) {
        super.configure(with: event)

        evaluator.registerKey(.hasRequiredData) { [weak self] in
            guard let `self` = self else { return false }
            return self.location != nil
                && self.hold != nil
        }
    }

    // MARK: - MediaContainer

    public func add(_ media: [MediaAsset]) {
        media.forEach {
            if !self.media.contains($0) {
                self.media.append($0)
            }
        }
    }

    public func remove(_ media: [MediaAsset]) {
        media.forEach { asset in
            if let index = self.media.index(where: { $0 == asset }) {
                self.media.remove(at: index)
            }
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case location
        case towReason
        case authorisingOfficer
        case notifyingOfficer
        case date
        case hold
        case holdReason
        case holdRemarks
        case media
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        location = try container.decode(EventLocation.self, forKey: .location)
        towReason = try container.decodeIfPresent(String.self, forKey: .towReason)
        authorisingOfficer = try container.decodeIfPresent(Officer.self, forKey: .authorisingOfficer)
        notifyingOfficer = try container.decodeIfPresent(Officer.self, forKey: .notifyingOfficer)
        date = try container.decodeIfPresent(Date.self, forKey: .date)
        hold = try container.decodeIfPresent(Bool.self, forKey: .hold)
        holdReason = try container.decodeIfPresent(String.self, forKey: .holdReason)
        holdRemarks = try container.decodeIfPresent(String.self, forKey: .holdRemarks)
        media = try container.decode([MediaAsset].self, forKey: .media)

        try super.init(from: decoder)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(location, forKey: CodingKeys.location)
        try container.encode(towReason, forKey: CodingKeys.towReason)
        try container.encode(authorisingOfficer, forKey: CodingKeys.authorisingOfficer)
        try container.encode(notifyingOfficer, forKey: CodingKeys.notifyingOfficer)
        try container.encode(date, forKey: CodingKeys.date)
        try container.encode(hold, forKey: CodingKeys.hold)
        try container.encode(holdReason, forKey: CodingKeys.holdReason)
        try container.encode(holdRemarks, forKey: CodingKeys.holdRemarks)
        try container.encode(media, forKey: CodingKeys.media)
    }

}

extension AdditionalActionType {
    public static let vehicleTow = AdditionalActionType(rawValue: "Vehicle Tow Report")
}
