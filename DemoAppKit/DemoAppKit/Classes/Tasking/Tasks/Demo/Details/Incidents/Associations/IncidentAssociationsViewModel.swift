//
//  IncidentAssociationsViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 12/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class IncidentAssociationsViewModel: CADFormCollectionViewModel<AssociationItemViewModel>, TaskDetailsViewModel {
    
    /// Create the view controller for this view model
    open func createViewController() -> TaskDetailsViewController {
        return AssociationsViewController(viewModel: self)
    }

    public func reloadFromModel(_ model: CADTaskListItemModelType) {
        guard let incident = model as? CADIncidentType else { return }

        var sections: [CADFormCollectionSectionViewModel<AssociationItemViewModel>] = []
        
        let personsViewModels = incident.persons.map { person in
            return AssociationItemViewModel(
                association: person,
                category: person.source,
                entityType: .person(initials: person.initials, thumbnailUrl: person.thumbnailUrl),
                title: person.fullName,
                detail1: formattedDOBAgeGender(person),
                detail2: person.fullAddress,
                borderColor: person.alertLevel?.color,
                iconColor: nil,
                badge: 0)
        }
        
        let vehiclesViewModels = incident.vehicles.map { vehicle in
            return AssociationItemViewModel(
                association: vehicle,
                category: vehicle.source,
                entityType: .vehicle,
                title: vehicle.plateNumber,
                detail1: [vehicle.year, vehicle.make, vehicle.model].joined(),
                detail2: [vehicle.primaryColour, vehicle.bodyType].joined(),
                borderColor: vehicle.associatedAlertLevel?.color,
                iconColor: vehicle.alertLevel?.color,
                badge: 0)
        }
        
        if personsViewModels.count > 0 {
            let title = String.localizedStringWithFormat(NSLocalizedString("%d Person(s)", comment: ""), personsViewModels.count)
            sections.append(CADFormCollectionSectionViewModel(title: title, items: personsViewModels))
        }
        
        if vehiclesViewModels.count > 0 {
            let title = String.localizedStringWithFormat(NSLocalizedString("%d Vehicle(s)", comment: ""), vehiclesViewModels.count)
            sections.append(CADFormCollectionSectionViewModel(title: title, items: vehiclesViewModels))
        }
        self.sections = sections
    }
    
    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("Associations", comment: "Associations sidebar title")
    }
    
    /// Content title shown when no results
    override open func noContentTitle() -> String? {
        return NSLocalizedString("No Associations Found", comment: "")
    }
    
    override open func noContentSubtitle() -> String? {
        return nil
    }

    /// Return the DOB, age and gender according to creative. eg 08/05/1987 (31 Male)
    open func formattedDOBAgeGender(_ person: CADAssociatedPersonType) -> String? {
        if let dob = person.dateOfBirth {
            let ageAndGender = "(\([String(dob.dobAge()), person.gender?.title].joined()))"
            return [dob.asPreferredDateString(), ageAndGender].joined(separator: " ")
        } else if let gender = person.gender {
            return gender.title + " (\(NSLocalizedString("DOB unknown", comment: "")))"
        } else {
            return NSLocalizedString("DOB and gender unknown", comment: "")
        }
    }

}

