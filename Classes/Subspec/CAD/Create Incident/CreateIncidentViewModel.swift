//
//  CreateIncidentViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 20/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

public protocol CreateIncidentViewModelDelegate: class {
    func contentChanged()
}

open class CreateIncidentViewModel {

    open let contentViewModel = CreateIncidentDetailsContentViewModel()

    open weak var delegate: CreateIncidentViewModelDelegate?
    
    init() {
        _ = LocationManager.shared.requestPlacemark().then { [weak self] placemark -> Void in
            let address = (placemark.addressDictionary?["FormattedAddressLines"] as? [String])?
                .joined(separator: ", ")
                .ifNotEmpty() ?? "Unknown Location"
            
            self?.contentViewModel.location = address
            self?.delegate?.contentChanged()

            return ()
        }
    }
    
    open var priorityOptions: [String] {
        return IncidentGrade.allCases.map({ $0.rawValue })
    }
    
    open var primaryCodeOptions: [String] {
        // TODO: Get from manifest
        return ["221 Traffic Hazard", "612 Wanted/Suspect Person", "620 Property Dispute"]
    }
    
    open var secondaryCodeOptions: [String] {
        // TODO: Get from manifest
        return ["Traffic", "Crash", "Other"]
    }
    
    open func navTitle() -> String {
        return NSLocalizedString("Create New Incident", comment: "")
    }
    
    open func createStatusViewController() -> CreateIncidentStatusViewController {
        let initialStatus = ResourceStatus.atIncident
        let sections = [CADFormCollectionSectionViewModel(
            title: NSLocalizedString("Initial Status", comment: "").uppercased(),
            items: [
                ManageCallsignStatusItemViewModel(.proceeding),
                ManageCallsignStatusItemViewModel(.atIncident),
                ManageCallsignStatusItemViewModel(.finalise),
                ManageCallsignStatusItemViewModel(.inquiries2) ])
        ]
        let viewModel = CreateIncidentStatusViewModel(sections: sections, selectedStatus: initialStatus)
        
        return viewModel.createViewController()
    }

    open func createFormViewController() -> IncidentDetailsFormViewController {
        return IncidentDetailsFormViewController(viewModel: self)
    }
    
    open func createViewController() -> CreateIncidentViewController {
        let vc = CreateIncidentViewController(viewModel: self)
        delegate = vc
        return vc
    }
    
    open func submitForm() {
        // TODO: Create network request, get content data and status data
        
    }
}
