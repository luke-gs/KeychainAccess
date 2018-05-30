//
//  Person+EntitySummaryDisplayable.swift
//  ClientKit
//
//  Created by KGWH78 on 7/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public struct PersonSummaryDisplayable: EntitySummaryDisplayable {

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
        return formattedSuburbStatePostcode()
    }
    
    public var borderColor: UIColor? {
        return person.alertLevel?.color
    }

    public var iconColor: UIColor? {
        return UIColor(white: 0.2, alpha: 1.0)
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
            return gender.description + " (\(NSLocalizedString("DOB unknown", bundle: .mpolKit, comment: "")))"
        } else {
            return NSLocalizedString("DOB and gender unknown", bundle: .mpolKit, comment: "")
        }
    }
    
    private func formattedSuburbStatePostcode() -> String? {
        let address = person.addresses?.first
        
        if let address = address {
            
            let components = [address.county, address.suburb, address.state, address.postcode].compactMap { $0 }
            if components.isEmpty == false {
                return components.joined(separator: ", ")
            }
        }
        
        return nil
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
