//
//  OfficerListItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 23/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public struct OfficerListItemViewModel: CustomSearchDisplayable {

    public var id: String
    public var firstName: String?
    public var lastName: String?
    public var initials: String?
    public var rank: String
    public var employeeNumber: String

    public init(id: String, firstName: String?, lastName: String?, initials: String?, rank: String?, employeeNumber: String?, section: String?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.initials = initials
        self.rank = rank ?? NSLocalizedString("Unknown Rank", comment: "Unknown Officer Rank Text")
        self.employeeNumber = employeeNumber ?? NSLocalizedString("Unknown Employee Number", comment: "Unknown Officer Employee Number Text")
        self.section = section ?? NSLocalizedString("Unknown Section", comment: "Unknown Officer Section Text")
    }

    // MARK: - Searchable

    public var title: StringSizable? {

        // compile title
        let lastNameString = lastName != nil ? "\(lastName!)," : ""
        let names = [lastNameString, firstName].joined()
        let employeeNumberString = NSMutableAttributedString(" (\(employeeNumber))", font: UIFont.systemFont(ofSize: 15))

        return NSMutableAttributedString(string: names).append(attributedString: employeeNumberString)
    }

    public var subtitle: StringSizable? {

        return rank
    }

    public var section: String?
    public var image: UIImage? {
        if let initials = initials {
            return UIImage.thumbnail(withInitials: initials).withCircleBackground(tintColor: nil,
                                                                                  circleColor: .disabledGray,
                                                                                  style: .fixed(size: CGSize(width: 48, height: 48),
                                                                                                padding: CGSize(width: 14, height: 14)))
        }
        return nil
    }

    public func contains(_ searchText: String) -> Bool {
        let searchStringLowercase = searchText.lowercased()

        let matchesFirstName = firstName?.lowercased().hasPrefix(searchStringLowercase)
        let matchesLastName = lastName?.lowercased().hasPrefix(searchStringLowercase)
        let matchesEmployeeNumber = employeeNumber.lowercased().hasPrefix(searchStringLowercase)

        return matchesFirstName.isTrue || matchesLastName.isTrue || matchesEmployeeNumber
    }

}
