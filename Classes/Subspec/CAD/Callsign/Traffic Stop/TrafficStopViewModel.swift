//
//  TrafficStopViewModel.swift
//  MPOLKit
//
//  Created by Megan Efron on 30/11/17.
//

import PromiseKit

open class TrafficStopViewModel {
    
    open private(set) var entities: [SelectStoppedEntityItemViewModel] = []
    
    // MARK: - Lifecycle
    
    public init() {
        
    }
    
    /// Create the view controller for this view model
    open func createViewController() -> UIViewController {
        return TrafficStopViewController(viewModel: self)
    }
    
    /// Title for VC
    open func navTitle() -> String {
        return NSLocalizedString("Traffic Stop", comment: "Traffic Stop title")
    }

}
