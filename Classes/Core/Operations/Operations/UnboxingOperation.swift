//
//  UnboxingOperation.swift
//  MPOLKit
//
//  Created by Herli Halim on 18/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import Alamofire

public class UnboxingOperation<UnboxableType: Unboxable>: DataResponseChainableOperation<URLJSONRequestOperation, UnboxableType> {
    
    public let keyPath: String?
    
    public init(provider: URLJSONRequestOperation, keyPath: String?, completionHandler: ((DataResponse<UnboxableType>) -> Void)? = nil) {
        self.keyPath = keyPath
        super.init(provider: provider, completionHandler: completionHandler)
    }
    
    public required convenience init(provider: URLJSONRequestOperation, completionHandler: ((DataResponse<UnboxableType>) -> Void)? = nil) {
        self.init(provider: provider, keyPath: nil, completionHandler: completionHandler)
    }

    override public func execute() {
        
        guard let providerData = providerOperation.response else {
            // Finish with errors here
            finish(with: NSError(code: .executionFailed))
            
            return
        }
        
        do {
            guard let json = providerData.value as? UnboxableDictionary else {
                throw ParsingError.notParsable
            }
            
            let unboxed: UnboxableType
            if let keyPath = keyPath {
                unboxed = try unbox(dictionary: json, atKey: keyPath)
            } else {
                unboxed = try unbox(dictionary: json)
            }
            
            response = DataResponse(inputResponse: providerData, result: Result.success(unboxed))
            finish()
            completionHandler?(response!)
        } catch {
            response = DataResponse(inputResponse: providerData, result: Result.failure(error))
            finish(with: error as NSError)
            completionHandler?(response!)
        }
    }
}

public class UnboxingGroupOperation<UnboxableType: Unboxable>: GroupOperation, HasDataResponse {
    
    public let completionHandler: ((DataResponse<UnboxableType>) -> Void)?
    
    public var response: DataResponse<UnboxableType>? {
        get {
            return self.unboxer.response
        }
    }
    
    private let provider: URLJSONRequestOperation
    private let unboxer: UnboxingOperation<UnboxableType>
    
    public required init(provider: URLJSONRequestOperation, unboxer: UnboxingOperation<UnboxableType>, completionHandler: ((DataResponse<UnboxableType>) -> Void)? = nil) {
        
        self.completionHandler = completionHandler
        self.provider = provider
        self.unboxer = unboxer
        
        unboxer.addDependency(provider)
        
        super.init(operations: [provider, unboxer])
        
        let completionHandlerTriggerOperation = Foundation.BlockOperation { [weak self] in
            if let response = self?.response {
                self?.completionHandler?(response)
            }
        }
        completionHandlerTriggerOperation.addDependency(unboxer)
        
        addOperation(operation: completionHandlerTriggerOperation)
    }
    
}
