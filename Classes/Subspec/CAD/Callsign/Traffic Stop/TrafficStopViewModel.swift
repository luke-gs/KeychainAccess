//
//  TrafficStopViewModel.swift
//  MPOLKit
//
//  Created by Megan Efron on 30/11/17.
//

import PromiseKit

public protocol TrafficStopViewModelDelegate: class {
    func reloadData()
}

open class TrafficStopViewModel {
    
    // MARK: - Properties
    
    open weak var delegate: TrafficStopViewModelDelegate?
    
    /// The completion handler for creating new traffic stop incident
    open var completionHandler: ((CADTrafficStopDetailsType?) -> Void)?

    // Model representing UI
    open var entities: [SelectStoppedEntityItemViewModel] = []
    open var location: CLPlacemark?
    open var createIncident: Bool = false
    open var priority: CADIncidentGradeType?
    open var primaryCode: String?
    open var secondaryCode: String?
    open var remark: String?
    
    // Options - where are these coming from?
    open var priorityOptions: [String] {
        return CADClientModelTypes.incidentGrade.allCases.map({ $0.rawValue })
    }
    
    open var primaryCodeOptions: [String] {
        return ["Traffic", "Crash", "Other"]
    }
    
    open var secondaryCodeOptions: [String] {
        return ["Traffic", "Crash", "Other"]
    }
    
    // MARK: - Lifecycle
    
    public init() {}
    
    /// Create the view controller for this view model
    open func createViewController() -> UIViewController {
        return TrafficStopViewController(viewModel: self)
    }
    
    /// View model for adding an entity
    open func viewModelForAddingEntity() -> SelectStoppedEntityViewModel {
        let viewModel = SelectStoppedEntityViewModel()
        viewModel.onSelectEntity = { [unowned self] entity -> Void in
            if !self.entities.contains(entity) {
                self.entities.append(entity)
                self.delegate?.reloadData()
            }
        }
        return viewModel
    }
    
    /// Title for VC
    open func navTitle() -> String {
        return NSLocalizedString("Traffic Stop", comment: "Traffic Stop title")
    }
    
    /// The formatted title for the location
    open func formattedLocation() -> String {
        if let location = location {
            return (location.addressDictionary?["FormattedAddressLines"] as? [String])?
                .joined(separator: ", ")
                .ifNotEmpty() ?? "Unknown Location"
        } else {
            return "Required"
        }
    }
    
    /// MARK: - Actions
    
    /// Final validation after form builder passes validation.
    open func validateForm() -> (success: Bool, message: String?) {
        if entities.isEmpty {
            return (false, NSLocalizedString("Please select an entity", comment: ""))
        }
        
        return (true, nil)
    }
    
    /// Perform any logic when submitting
    open func submit() {
        // TODO: Fill request object with details
        let trafficStop = CADClientModelTypes.trafficStopDetails.init()
        
        // Complete with new request
        completionHandler?(trafficStop)
        completionHandler = nil
    }
    
    /// Perform any logic when cancelling
    open func cancel() {
        // Complete with nothing
        completionHandler?(nil)
        completionHandler = nil
    }

}
