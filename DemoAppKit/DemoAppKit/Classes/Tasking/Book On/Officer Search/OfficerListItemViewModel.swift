//
//  OfficerListItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 23/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PatternKit

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
        self.rank = rank ?? "Unknown"
        self.employeeNumber = employeeNumber ?? "Unknown"
        self.section = section
    }

    // MARK: - Searchable

    public var title: String? {
        let lastNameString = lastName != nil ? "\(lastName!)," : ""
        let employeeNumberString = "(\(employeeNumber))"
        return [lastNameString, firstName, employeeNumberString].joined()
    }

    public var attributedTitle: StringSizable? {

        guard let title = title else { return nil }

        let employeeNumberCount = employeeNumber.count + 2
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15), range: NSRange(location: (title.count - employeeNumberCount), length: employeeNumberCount))
        return attributedString
    }

    public var subtitle: String? {

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
