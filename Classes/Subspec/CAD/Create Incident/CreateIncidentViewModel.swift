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

    open weak var delegate: CreateIncidentViewModelDelegate?
    
    open lazy var contentViewModel: CreateIncidentFormViewModel = {
        return CreateIncidentFormViewModel()
    }()

    open lazy var statusViewModel: CreateIncidentStatusViewModel = {
        let incidentItems = CADClientModelTypes.resourceStatus.incidentCases.map {
            return ManageCallsignStatusItemViewModel($0)
        }
        let sections = [CADFormCollectionSectionViewModel(
            title: NSLocalizedString("Initial Status", comment: "").uppercased(),
            items: incidentItems)
        ]
        return CreateIncidentStatusViewModel(sections: sections, selectedStatus: initialStatus)
    }()

    public init() {
        getLocation()
    }
    
    private func getLocation() {
        _ = LocationManager.shared.requestPlacemark().done { [weak self] placemark -> Void in
            let address = (placemark.addressDictionary?["FormattedAddressLines"] as? [String])?
                .joined(separator: ", ")
                .ifNotEmpty() ?? "Unknown Location"
            
            self?.contentViewModel.location = address
            self?.delegate?.contentChanged()
            
            return ()
        }
    }
    
    open var initialStatus: CADResourceStatusType {
        return CADClientModelTypes.resourceStatus.defaultCreateCase
    }

    open var priorityOptions: [String] {
        return CADClientModelTypes.incidentGrade.allCases.map({ $0.rawValue })
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

    open func createViewController() -> CreateIncidentViewController {
        let vc = CreateIncidentViewController(viewModel: self)
        delegate = vc
        return vc
    }
    
    open func configureLoadingManager(_ loadingManager: LoadingStateManager) {
        loadingManager.loadingView.titleLabel.text = NSLocalizedString("Please Wait", comment: "")
        loadingManager.loadingView.subtitleLabel.text =  NSLocalizedString("We're creating your incident", comment: "")
        loadingManager.loadingView.actionButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        loadingManager.errorView.titleLabel.text =  NSLocalizedString("Network Error", comment: "")
    }
    
    open func submitForm() -> Promise<Void> {
        return firstly {
            // TODO: Create network request, get content data and status data
            return after(seconds: 2.0)
        }
    }
}
