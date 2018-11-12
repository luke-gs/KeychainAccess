//
//  TrafficInfringementServiceReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit

fileprivate extension EvaluatorKey {
    static let hasContactDetails = EvaluatorKey("hasContactDetails")
}

class TrafficInfringementServiceReport: DefaultReportable {

    open var selectedServiceType: ServiceType?
    open var selectedEmail: String?
    open var selectedMobile: String?
    open var selectedAddress: String?

    var hasContactDetails: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .hasContactDetails)
        }
    }

    public override init(event: Event, incident: Incident) {
        super.init(event: event, incident: incident)
        commonInit()
    }

    private func commonInit() {
        evaluator.registerKey(.hasContactDetails) { [weak self] in
            return self?.hasContactDetails ?? false
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case selectedServiceType
        case selectedEmail
        case selectedMobile
        case selectedAddress
        case hasContactDetails
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selectedServiceType = try container.decodeIfPresent(ServiceType.self, forKey: .selectedServiceType)
        selectedEmail = try container.decodeIfPresent(String.self, forKey: .selectedEmail)
        selectedMobile = try container.decodeIfPresent(String.self, forKey: .selectedMobile)
        selectedAddress = try container.decodeIfPresent(String.self, forKey: .selectedAddress)
        hasContactDetails = try container.decode(Bool.self, forKey: .hasContactDetails)

        try super.init(from: decoder)
        commonInit()
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selectedServiceType, forKey: CodingKeys.selectedServiceType)
        try container.encode(selectedEmail, forKey: CodingKeys.selectedEmail)
        try container.encode(selectedMobile, forKey: CodingKeys.selectedMobile)
        try container.encode(selectedAddress, forKey: CodingKeys.selectedAddress)
        try container.encode(hasContactDetails, forKey: CodingKeys.hasContactDetails)
    }

}

extension TrafficInfringementServiceReport: Summarisable {
    var formItems: [FormItem] {
        var items = [FormItem]()
        if let email = selectedEmail {
            items.append(RowDetailFormItem(title: "Email", detail: email))
        }
        if let mobile = selectedMobile {
            items.append(RowDetailFormItem(title: "Mobile", detail: mobile))
        }
        if let address = selectedAddress {
            items.append(RowDetailFormItem(title: "Address", detail: address))
        } else if items.isEmpty {
            items.append(RowDetailFormItem(title: "No Service Details Set", detail: nil))
        }
        return items
    }
}
