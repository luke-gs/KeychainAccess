//
//  OrderSummaryViewModel.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//
import Foundation
import MPOLKit

public class OrderSummaryViewModel {
    private var order: Order

    var type: StringSizable {
        let type = order.type ?? "Unknown"

        return NSAttributedString(string: type,
                            attributes: [.font: UIFont.systemFont(ofSize: 28, weight: .bold)])
    }

    var statusLabel: StringSizable {
        return "Status".withPrefferedFont
    }

    var statusValue: StringSizable {
        let status = order.status ?? "Unknown"
        return status.withPrefferedFont
    }

    var issuingAuthorityLabel: StringSizable {
        return "Issuing Authority".withPrefferedFont
    }

    var issuingAuthorityValue: StringSizable {
        let issuingAuthority = order.issuingAuthority ?? "Unknown"
        return issuingAuthority.withPrefferedFont
    }

    var dateIssuedLabel: StringSizable {
        return "Date Issued".withPrefferedFont
    }

    var dateIssuedValue: StringSizable {
        
        if let date = order.issuedDate {
            let formatedDate = DateFormatter.preferredDateStyle.string(from: date)
            return formatedDate.withPrefferedFont
        }
        return "Unknown".sizing()
    }

    var dateOfExpiryLabel: StringSizable {
        return "Date of Expiry".withPrefferedFont
    }

    var dateOfExpiryValue: StringSizable {

        if let date = order.expiryDate {
            let formatedDate = DateFormatter.preferredDateStyle.string(from: date)
            return formatedDate.withPrefferedFont
        }
        return "Unknown".sizing()
    }

    var orderDescription: String {
        return order.orderDescription ?? "Unknown"
    }

    init(order: Order) {
        self.order = order
    }
}

fileprivate extension String {

    var withPrefferedFont: StringSizable {
        return NSAttributedString(string: self,
                                  attributes: [.font: UIFont.systemFont(ofSize:17.0)])
            .sizing()
    }
}
