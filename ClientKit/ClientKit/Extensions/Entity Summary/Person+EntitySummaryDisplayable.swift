//
//  Person+EntitySummaryDisplayable.swift
//  ClientKit
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
    
    public var title: String? {
        return formattedName ?? NSLocalizedString("Name Unknown", comment: "")
    }
    
    public var detail1: String? {
        return formattedDOBAgeGender()
    }
    
    public var detail2: String? {
        return formattedAddress()
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
    
    private func formattedDOBAgeGender() -> String? {
        if let dob = person.dateOfBirth {
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
        var components = [address.suburb, address.state?.uppercased(), address.postcode].compactMap { $0 }
        if withNewLine && !components.isEmpty {
            components.insert("\n", at: 0)
        }
        if let county = address.county {
            components.insert(county, at: 0)
        }
        guard !components.isEmpty else { return nil }
        return shortAddressForm + ", " + components.joined(separator: " ")
    }
    
    private func formattedAssociationReason() -> String? {
        guard let lastReason = person.associatedReasons?.last else { return nil }
        return lastReason.formattedReason()
    }

    public func summaryThumbnailFormItem(with style: EntityCollectionViewCell.Style) -> SummaryThumbnailFormItem {
        return SummaryThumbnailFormItem()
            .style(style)
            .width(.column(2))
            .category(category)
            .title(title?.sizing(withNumberOfLines: style == .hero ? 0 : 1))
            .subtitle(detail1?.sizing(withNumberOfLines: style == .hero ? 0 : 1))
            .detail((formattedAddress(withNewLine: true) ?? "").sizing(withNumberOfLines: style == .hero ? 0 : 2))
            .badge(badge)
            .badgeColor(borderColor)
            .image(thumbnail(ofSize: style == .hero ? .large : .medium))
            .borderColor(borderColor)
            .imageTintColor(iconColor)
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

    public var title: String? {
        return formattedName ?? NSLocalizedString("Name Unknown", comment: "")
    }

    public var detail1: String? {
        return displayable.detail1
    }

    public var detail2: String? {
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
