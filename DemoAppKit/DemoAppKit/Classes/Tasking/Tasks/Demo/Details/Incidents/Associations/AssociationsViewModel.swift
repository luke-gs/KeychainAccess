//
//  AssociationsViewModel.swift
//  DemoAppKit
//
//  Created by Campbell Graham on 12/9/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// Abstract base class for the view model for Associations (inside Incidents, Broadcasts etc.)
public class AssociationsViewModel: CADFormCollectionViewModel<AssociationItemViewModel>, TaskDetailsViewModel {

    open func createViewController() -> TaskDetailsViewController {
         return AssociationsViewController(viewModel: self)
    }

    open func reloadFromModel(_ model: CADTaskListItemModelType) {
        MPLRequiresConcreteImplementation()
    }

    open func formattedDOBAgeGender(_ person: CADAssociatedPersonType) -> String? {
        if let _ = person.dateOfDeath {
            // show deceased instead of DOB
            var dodString = NSLocalizedString("Deceased", comment: "")
            var yearComponent: DateComponents?
            
            if let dob = person.dateOfBirth {
                yearComponent = Calendar.current.dateComponents([.year], from: dob, to: Date())
            }
            
            if let year = yearComponent?.year, let gender = person.gender {
                dodString += " (\(year) \(gender.title))"
            } else if let year = yearComponent?.year {
                dodString += " (\(year))"
            } else if let gender = person.gender {
                dodString += " (\(gender.title))"
            }
            
            return dodString
        } else if let dob = person.dateOfBirth {
            let ageAndGender = "(\([String(dob.dobAge()), person.gender?.title].joined()))"
            return [dob.asPreferredDateString(), ageAndGender].joined(separator: " ")
        } else if let gender = person.gender {
            return gender.title + " (\(NSLocalizedString("DOB unknown", comment: "")))"
        } else {
            return NSLocalizedString("DOB and gender unknown", comment: "")
        }
    }

    open override func navTitle() -> String {
        return NSLocalizedString("Associations", comment: "Associations sidebar title")
    }

    open override func noContentTitle() -> String? {
        return NSLocalizedString("No Associations Found", comment: "")
    }

    open override func noContentSubtitle() -> String? {
        return nil
    }
}
