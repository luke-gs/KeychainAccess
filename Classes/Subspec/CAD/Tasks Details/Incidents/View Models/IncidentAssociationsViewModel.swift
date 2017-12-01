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
    public func createViewController() -> UIViewController {
        let viewController = IncidentAssociationsViewController(viewModel: self)
        delegate = viewController
        return viewController
    }
    
    open func loadData() {
        guard let incident = CADStateManager.shared.incidentsById[incidentNumber] else { return }
        sections = []
        
        let personsViewModels = incident.persons?.map { person in
            return IncidentAssociationItemViewModel(category: "DS1",
                                                    entityType: .person(initials: person.initials),
                                                    title: person.fullName,
                                                    detail1: "\(person.dateOfBirth ?? "") \(person.gender ?? "")",
                                                    detail2: person.jurisdiction, // TODO: Get address
                                                    borderColor: nil,
                                                    iconColor: nil,
                                                    badge: 0)
        } ?? []
        
        let vehiclesViewModels = incident.vehicles?.map { vehicle in
            return IncidentAssociationItemViewModel(category: "DS1",
                                                    entityType: .vehicle,
                                                    title: vehicle.plateNumber,
                                                    detail1: vehicle.vehicleType,
                                                    detail2: vehicle.vehicleDescription,
                                                    borderColor: nil,
                                                    iconColor: nil,
                                                    badge: 0)
        } ?? []
        
        if personsViewModels.count > 0 {
            sections.append(CADFormCollectionSectionViewModel(title: "\(personsViewModels.count) People", items: personsViewModels))
        }
        
        if vehiclesViewModels.count > 0 {
            sections.append(CADFormCollectionSectionViewModel(title: "\(vehiclesViewModels.count) Vehicles", items: vehiclesViewModels))
        }
        
        delegate?.sectionsUpdated()
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

