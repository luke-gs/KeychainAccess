//
//  Person+EntitySummaryDisplayable.swift
//  ClientKit
//
//  Created by KGWH78 on 7/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

extension Person: EntitySummaryDisplayable {
    
    public var category: String? {
        return source?.localizedBadgeTitle
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
    
    public var alertColor: UIColor? {
        return alertLevel?.color
    }
    
    public var badge: UInt {
        return actionCount
    }
    
    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> (image: UIImage, mode: UIViewContentMode)? {
        if let thumbnail = self.thumbnail {
            return (thumbnail, .scaleAspectFill)
        }
        if initials?.isEmpty ?? true == false {
            return (initialThumbnail, .scaleAspectFill)
        }
        return nil
    }
    
    // MARK: - Private
    
    private var formattedName: String? {
        var formattedName: String = ""
        
        if isAlias ?? false {
            formattedName += "@ "
        }
        
        if let surname = self.surname?.ifNotEmpty() {
            formattedName += surname
            
            if givenName?.isEmpty ?? true == false || middleNames?.isEmpty ?? true == false {
                formattedName += ", "
            }
        }
        if let givenName = self.givenName?.ifNotEmpty() {
            formattedName += givenName
            
            if middleNames?.isEmpty ?? true == false {
                formattedName += " "
            }
        }
        
        if let firstMiddleNameInitial = middleNames?.characters.first {
            formattedName.append(firstMiddleNameInitial)
            formattedName += "."
        }
        
        return formattedName
    }
    
    private func formattedDOBAgeGender() -> String? {
        if let dob = dateOfBirth {
            let yearComponent = Calendar.current.dateComponents([.year], from: dob, to: Date())
            
            var dobString = DateFormatter.mediumNumericDate.string(from: dob) + " (\(yearComponent.year!)"
            
            if let gender = gender {
                dobString += " \(gender.description))"
            } else {
                dobString += ")"
            }
            return dobString
        } else if let gender = gender {
            return gender.description + " (\(NSLocalizedString("DOB unknown", bundle: .mpolKit, comment: "")))"
        } else {
            return NSLocalizedString("DOB and gender unknown", bundle: .mpolKit, comment: "")
        }
    }
    
    private func formattedSuburbStatePostcode() -> String? {
        let address = addresses?.first
        
        if let address = address {
            
            let components = [address.county, address.suburb, address.state, address.postcode].flatMap { $0 }
            if components.isEmpty == false {
                return components.joined(separator: ", ")
            }
        }
        
        return nil
    }
}
