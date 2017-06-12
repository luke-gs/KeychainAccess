//
//  UnboxingArrayOperation.swift
//  MPOLKit
//
//  Created by Herli Halim on 2/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import Alamofire

public class UnboxingArrayOperation<UnboxableType: Unboxable>: DataResponseChainableOperation<URLJSONRequestOperation, [UnboxableType]> {
    
    public let keyPath: String?
    
    public init(provider: URLJSONRequestOperation, keyPath: String?, completionHandler: ((DataResponse<[UnboxableType]>) -> Void)? = nil) {
        self.keyPath = keyPath
        super.init(provider: provider, completionHandler: completionHandler)
    }
    
    public required convenience init(provider: URLJSONRequestOperation, completionHandler: ((DataResponse<[UnboxableType]>) -> Void)? = nil) {
        self.init(provider: provider, keyPath: nil, completionHandler: completionHandler)
    }
    
    override public func execute() {
        
        guard let providerData = providerOperation.response else {
            // Finish with errors here
            finish(with: NSError(code: .executionFailed))
            return
        }
        
        do {
            if let json = providerData.value as? UnboxableDictionary, let keyPath = keyPath {
                
                let unboxed: [UnboxableType] = try unbox(dictionary: json, atKey: keyPath)
                response = DataResponse(inputResponse: providerData, result: Result.success(unboxed))
                finish()
                completionHandler?(response!)
                
            } else if let json = providerData.value as? [UnboxableDictionary] {
                
                let unboxed: [UnboxableType] = try unbox(dictionaries: json)
                response = DataResponse(inputResponse: providerData, result: Result.success(unboxed))
                finish()
                completionHandler?(response!)
                
            } else {
                throw ParsingError.notParsable
            }
            
        } catch {
            response = DataResponse(inputResponse: providerData, result: Result.failure(error))
            finish(with: error as NSError)
            completionHandler?(response!)
        }
        
    }
    
}

public class UnboxingArrayGroupOperation<UnboxableType: Unboxable>: GroupOperation, HasDataResponse {
    
    public let completionHandler: ((DataResponse<[UnboxableType]>) -> Void)?
    
    public var response: DataResponse<[UnboxableType]>? {
        get {
            return self.unboxer.response
        }
    }
    
    private let provider: URLJSONRequestOperation
    private let unboxer: UnboxingArrayOperation<UnboxableType>
    
    public required init(provider: URLJSONRequestOperation, unboxer: UnboxingArrayOperation<UnboxableType>, completionHandler: ((DataResponse<[UnboxableType]>) -> Void)?) {
        
        self.completionHandler = completionHandler
        self.provider = provider
        self.unboxer = unboxer
        
        unboxer.addDependency(provider)
        
        super.init(operations: [provider, unboxer])
        
        let completionHandlerTriggerOperation = BlockOperation { [weak self] in
            if let response = self?.response {
                self?.completionHandler?(response)
            }
        }
        
        addOperation(operation: completionHandlerTriggerOperation)
    }
    
}
