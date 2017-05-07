//
//  URLJSONRequestOperation.swift
//  MPOLKit
//
//  Created by Rod Brown on 6/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import Alamofire

/// An abstract operation subclass for network actions with Alamofire requests.
///
/// `URLRequestOperation` lazily loads the Request object by calling the `loadRequest()`
/// method as execution begins. This allows last minute alteration of the request or its
/// backing URLRequest if desired. Subclasses should override this method and set the
/// `request` property.
///
/// This operation automatically manages registering network activity with the
/// `NetworkMonitor`.
open class URLRequestOperation: Operation {
    
    
    // MARK: - Properties
    
    open var request: Alamofire.Request?
    
    /// The errors aggregated throughout the operation.
    private var aggregatedErrors = [NSError]()
    
    
    // MARK: - Initializer
    
    override public init() {
        super.init()
        addObserver(NetworkObserver())
    }
    
    
    // MARK: - Override points
    
    open func loadRequest() {
        fatalError("Subclasses must override loadRequest() and set a valid request.")
    }
    
    
    // MARK: - Execution
    
    open override func execute() {
        if request == nil { loadRequest() }
        
        assert(request != nil, "Request should be loaded by the time loadRequest is called.")
        
        guard let request = self.request else {
            aggregateError(NSError(code: .executionFailed))
            finish(with: aggregatedErrors)
            return
        }
        
        request.delegate.queue.addOperation { [weak self] in self?.requestDidFinish() }
        request.resume()
    }
    
    open override func cancel() {
        if let request = self.request {
            request.delegate.queue.cancelAllOperations()
            request.cancel()
        }
        super.cancel()
    }
    
    /// Notes that some part of the execution has produced an error.
    ///
    /// Errors aggregated through this method will be included in the final array
    /// of errors reported to observers, and to the `finished(_:)` method.
    ///
    /// - Parameter error: An error to add to the aggregated error list.
    public final func aggregateError(_ error: NSError) {
        aggregatedErrors.append(error)
    }
    
    
    // MARK: - Private methods
    
    private func requestDidFinish() {
        if let error = request?.delegate.error as NSError? {
            if aggregatedErrors.contains(error) == false {
                aggregateError(error)
            }
        }
        finish(with: aggregatedErrors)
    }
}

