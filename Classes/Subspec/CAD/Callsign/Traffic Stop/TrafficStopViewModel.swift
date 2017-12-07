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
    
    /// The promise that fulfills/cancels on form submission
    open let promise: Promise<TrafficStopRequest>.PendingTuple
    
    // Model representing UI
    open var entities: [SelectStoppedEntityItemViewModel] = []
    open var location: String?
    open var createIncident: Bool
    open var priority: IncidentGrade?
    open var primaryCode: String?
    open var secondaryCode: String?
    open var remark: String?
    
    // Options - where are these coming from?
    open var priorityOptions: [String] {
        return IncidentGrade.allCases.map({ $0.rawValue })
    }
    
    open var primaryCodeOptions: [String] {
        return ["Traffic", "Crash", "Other"]
    }
    
    open var secondaryCodeOptions: [String] {
        return ["Traffic", "Crash", "Other"]
    }
    
    // MARK: - Lifecycle
    
    public init(location: String? = nil, createIncident: Bool = false, priority: IncidentGrade? = nil, primaryCode: String? = nil, secondaryCode: String? = nil, remark: String? = nil) {
        promise = Promise<TrafficStopRequest>.pending()
        
        self.location = location
        self.createIncident = createIncident
        self.priority = priority
        self.primaryCode = primaryCode
        self.secondaryCode = secondaryCode
        self.remark = remark
    }
    
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
        let trafficStop = TrafficStopRequest()
        
        // Fulfill promise with details
        self.promise.fulfill(trafficStop)
    }
    
    /// Perform any logic when cancelling
    open func cancel() {
        // Cancel promise
        promise.reject(NSError.cancelledError())
    }

}
