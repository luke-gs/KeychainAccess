//
//  Person+EntitySummaryDisplayable.swift
//  MPOL
//
//  Created by KGWH78 on 7/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public struct PersonSummaryDisplayable: AssociatedEntitySummaryDisplayable {

    private var person: Person

    public init(_ entity: MPOLKitEntity) {
        person = entity as! Person
    }

    public var category: String? {
        return person.source?.localizedBarTitle
    }

    public var title: StringSizable? {
        return (formattedName ?? NSLocalizedString("Name Unknown", comment: "")).sizing(withNumberOfLines: 0)
    }

    public var detail1: StringSizable? {
        return formattedPersonStatus()?.sizing(defaultNumberOfLines: 0)
    }

    public var detail2: StringSizable? {
        return formattedAddress()?.sizing(withNumberOfLines: 0)
    }

    public var association: String? {
        return person.formattedAssociationReasonsString()
    }

    public var borderColor: UIColor? {
        return person.alertLevel?.color
    }

    public var iconColor: UIColor? {
        return nil
    }

    public var badge: UInt {
        return person.actionCount
    }

    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> ImageLoadable? {
        return PersonImageSizing(person: person)
    }

    public var priority: Int {
        return person.alertLevel?.rawValue ?? -1
    }

    // MARK: - Private

    private var formattedName: String? {
        var formattedName: String = ""

        if person.isAlias ?? false {
            formattedName += "@ "
        }

        if let surname = person.familyName?.ifNotEmpty() {
            formattedName += surname

            if person.givenName?.isEmpty ?? true == false || person.middleNames?.isEmpty ?? true == false {
                formattedName += ", "
            }
        }
        if let givenName = person.givenName?.ifNotEmpty() {
            formattedName += givenName

            if person.middleNames?.isEmpty ?? true == false {
                formattedName += " "
            }
        }

        if let firstMiddleNameInitial = person.middleNames?.first {
            formattedName.append(firstMiddleNameInitial)
            formattedName += "."
        }

        return formattedName
    }

    /// Generates a string containing date of birth/date of death, age, gender
    /// - Returns: NSMutableAttributedString if deceased otherwise NSlocalizedString
    private func formattedPersonStatus() -> StringSizable? {
        if let dod = person.dateOfDeath {
            // show deceased instead of DOB
            var dodString = NSLocalizedString("Deceased", comment: "")
            var yearComponent: DateComponents?

            if let dob = person.dateOfBirth {
                yearComponent = Calendar.current.dateComponents([.year], from: dob, to: dod)
            }

            if let year = yearComponent?.year, let gender = person.gender {
                dodString += " (\(year) \(gender.description))"
            } else if let year = yearComponent?.year {
                dodString += " (\(year))"
            } else if let gender = person.gender {
                dodString += " (\(gender.description))"
            }

            return NSMutableAttributedString.init(string: dodString,
                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.orangeRed,
                                                               NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .bold)])
        } else if let dob = person.dateOfBirth {
            let yearComponent = Calendar.current.dateComponents([.year], from: dob, to: Date())

            var dobString = DateFormatter.preferredDateStyle.string(from: dob) + " (\(yearComponent.year!)"

            if let gender = person.gender {
                dobString += " \(gender.description))"
            } else {
                dobString += ")"
            }
            return dobString
        } else if let gender = person.gender {
            return gender.description + " (\(NSLocalizedString("DOB unknown", comment: "")))"
        } else {
            return NSLocalizedString("DOB and gender unknown", comment: "")
        }
    }

    private func formattedAddress(withNewLine: Bool = false) -> String? {
        guard let address = person.addresses?.first else { return nil }
        guard let shortAddressForm = AddressFormatter(style: .short).formattedString(from: address) else { return nil }
        var components = [address.suburb, address.county, address.state?.uppercased(), address.postcode].compactMap { $0 }
        guard !components.isEmpty else { return nil }
        if withNewLine {
            components.insert("\n", at: 0)
        }
        return shortAddressForm + ", " + components.joined(separator: " ")
    }

    private func formattedAssociationReason() -> String? {
        guard let lastReason = person.associatedReasons?.last else { return nil }
        return lastReason.formattedReason()
    }

    public func summaryThumbnailFormItem(with style: EntityCollectionViewCell.Style, containerType: EntitySummaryContainerType) -> SummaryThumbnailFormItem {

        let formItem = SummaryThumbnailFormItem()
            .style(style)
            .width(.column(2))
            .category(category)
            .title(title?.sizing().string.sizing(withNumberOfLines: style == .hero ? 0 : 1))
            .subtitle(detail1?.sizing(defaultNumberOfLines: style == .hero ? 0 : 1))
            .detail((formattedAddress(withNewLine: true) ?? "").sizing(withNumberOfLines: style == .hero ? 0 : 2))
            .badge(badge)
            .badgeColor(borderColor)
            .image(thumbnail(ofSize: style == .hero ? .large : .medium))
            .borderColor(borderColor)
            .imageTintColor(iconColor)

        switch containerType {
        case .header:
            formItem.styleIdentifier(PublicSafetyKitStyler.summaryThumbnailHeaderStyle)
        default:
            formItem.styleIdentifier(PublicSafetyKitStyler.summaryThumbnailListStyle)
        }
        return formItem
    }
}

public struct PersonDetailsDisplayable: EntitySummaryDisplayable {

    private var person: Person
    private var displayable: PersonSummaryDisplayable

    public init(_ entity: MPOLKitEntity) {
        person = entity as! Person
        displayable = PersonSummaryDisplayable(person)
    }

    public var category: String? {
        return person.source?.localizedBadgeTitle
    }

    public var title: StringSizable? {
        return formattedName ?? NSLocalizedString("Name Unknown", comment: "")
    }

    public var detail1: StringSizable? {
        return displayable.detail1
    }

    public var detail2: StringSizable? {
        return displayable.detail2
    }

    public var borderColor: UIColor? {
        return displayable.borderColor
    }

    public var iconColor: UIColor? {
        return displayable.iconColor
    }

    public var badge: UInt {
        return displayable.badge
    }

    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> ImageLoadable? {
        return displayable.thumbnail(ofSize: size)
    }

    public var priority: Int {
        return displayable.priority
    }

    // MARK: - Private

    private var formattedName: String? {
        var formattedName: String = ""

        if person.isAlias ?? false {
            formattedName += "@ "
        }

        if let surname = person.familyName?.ifNotEmpty() {
            formattedName += surname

            if person.givenName?.isEmpty ?? true == false || person.middleNames?.isEmpty ?? true == false {
                formattedName += ", "
            }
        }
        if let givenName = person.givenName?.ifNotEmpty() {
            formattedName += givenName

            if person.middleNames?.isEmpty ?? true == false {
                formattedName += " "
            }
        }

        if let middleNames = person.middleNames {
            formattedName += middleNames
        }

        return formattedName
    }
}
