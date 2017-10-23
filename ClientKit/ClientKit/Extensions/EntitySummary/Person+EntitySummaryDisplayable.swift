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
        return person.source?.localizedBadgeTitle
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
        return nil
    }
    
    public var badge: UInt {
        return person.actionCount
    }
    
    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> (image: UIImage, mode: UIViewContentMode)? {
        if let thumbnail = person.thumbnail {
            return (thumbnail, .scaleAspectFill)
        }
        if person.initials?.isEmpty ?? true == false {
            return (person.initialThumbnail, .scaleAspectFill)
        }
        return nil
    }
    
    // MARK: - Private
    
    private var formattedName: String? {
        var formattedName: String = ""
        
        if person.isAlias ?? false {
            formattedName += "@ "
        }
        
        if let surname = person.surname?.ifNotEmpty() {
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
            
            var dobString = DateFormatter.mediumNumericDate.string(from: dob) + " (\(yearComponent.year!)"
            
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
            
            let components = [address.county, address.suburb, address.state, address.postcode].flatMap { $0 }
            if components.isEmpty == false {
                return components.joined(separator: ", ")
            }
        }
        
        return nil
    }
}
