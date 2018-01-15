//
//  IncidentAssociationsViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 12/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class IncidentAssociationsViewModel: CADFormCollectionViewModel<EntitySummaryDisplayable>, TaskDetailsViewModel {
    
    /// The identifier for this incident
    open let incidentNumber: String
    
    public init(incidentNumber: String) {
        self.incidentNumber = incidentNumber
        super.init()
        loadData()
    }
    
    /// Create the view controller for this view model
    open func createViewController() -> TaskDetailsViewController {
        return IncidentAssociationsViewController(viewModel: self)
    }

    open func reloadFromModel() {
        loadData()
    }

    open func loadData() {
        guard let incident = CADStateManager.shared.incidentsById[incidentNumber] else { return }

        var sections: [CADFormCollectionSectionViewModel<EntitySummaryDisplayable>] = []
        
        let personsViewModels = incident.persons?.map { person in
            return IncidentAssociationItemViewModel(category: "DS1",
                                                    entityType: .person(initials: person.initials),
                                                    title: person.fullName,
                                                    detail1: "\(person.dateOfBirth ?? "") \(person.gender ?? "")",
                                                    detail2: person.fullAddress,
                                                    borderColor: nil,
                                                    iconColor: nil,
                                                    badge: 0)
        } ?? []
        
        let vehiclesViewModels = incident.vehicles?.map { vehicle in
            return IncidentAssociationItemViewModel(category: "DS1",
                                                    entityType: .vehicle,
                                                    title: vehicle.plateNumber,
                                                    detail1: vehicle.vehicleDescription,
                                                    detail2: [vehicle.bodyType, vehicle.color].joined(separator: ThemeConstants.dividerSeparator),
                                                    borderColor: nil,
                                                    iconColor: nil,
                                                    badge: 0)
        } ?? []
        
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
    
}

