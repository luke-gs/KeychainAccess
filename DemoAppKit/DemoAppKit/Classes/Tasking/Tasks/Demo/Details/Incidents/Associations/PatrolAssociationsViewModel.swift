//
//  PatrolAssociationsViewModel.swift
//  DemoAppKit
//
//  Created by Campbell Graham on 10/9/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public class PatrolAssociationsViewModel: AssociationsViewModel {

    public override func reloadFromModel(_ model: CADTaskListItemModelType) {
        guard let incident = model as? CADPatrolType else { return }

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
                subtitleColor: UIColor.red,
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
}
