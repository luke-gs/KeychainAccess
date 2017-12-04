//
//  TrafficStopViewModel.swift
//  MPOLKit
//
//  Created by Megan Efron on 30/11/17.
//

import PromiseKit

open class TrafficStopViewModel {
    
    // MARK: - Class Methods
    
    open static func prompt(using delegate: CADFormCollectionViewModelDelegate?) -> Promise<Void> {
        let viewModel = TrafficStopViewModel()
        delegate?.presentPushedViewController(viewModel.createViewController(), animated: true)
        return viewModel.promiseTuple.promise
    }
    
    // MARK: - Properties
    
    /// The promise that completes on user interaction.
    // TODO: Create traffic stop model and return in this promise
    open let promiseTuple: Promise<Void>.PendingTuple = Promise<Void>.pending()
    
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
