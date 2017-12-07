//
//  TrafficStopViewModel.swift
//  MPOLKit
//
//  Created by Megan Efron on 30/11/17.
//

import PromiseKit

open class TrafficStopViewModel {
    
    // MARK: - Properties
    
    /// The promise that fulfills/cancels on form submission
    open let promise: Promise<TrafficStopRequest>.PendingTuple
    
    // Model representing UI
    open var entities: [SelectStoppedEntityItemViewModel] = []
    open var location: String?
    open var createIncident: Bool
    open var priority: String?
    open var primaryCode: String?
    open var secondaryCode: String?
    open var remark: String?
    
    // Options - where are these coming from?
    open var priorityOptions: [String] {
        return ["P1", "P2", "P3", "P4"]
    }
    
    open var primaryCodeOptions: [String] {
        return ["Traffic", "Crash", "Other"]
    }
    
    open var secondaryCodeOptions: [String] {
        return ["Traffic", "Crash", "Other"]
    }
    
    // MARK: - Lifecycle
    
    public init(location: String? = nil, createIncident: Bool = false, priority: String? = nil, primaryCode: String? = nil, secondaryCode: String? = nil, remark: String? = nil) {
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
    
    /// Title for VC
    open func navTitle() -> String {
        return NSLocalizedString("Traffic Stop", comment: "Traffic Stop title")
    }
    
    /// MARK: - Actions
    
    /// Final validation after form builder passes validation.
    open func validateForm() -> (success: Bool, message: String?) {
        if entities.isEmpty {
            return (false, NSLocalizedString("Entity is required", comment: ""))
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
