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
    
    public init(provider: URLJSONRequestOperation, keyPath: String?, completionHandler: ((DataResponse<[UnboxableType]>) -> Void)?) {
        self.keyPath = keyPath
        super.init(provider: provider, completionHandler: completionHandler)
    }
    
    public required convenience init(provider: URLJSONRequestOperation, completionHandler: ((DataResponse<[UnboxableType]>) -> Void)?) {
        self.init(provider: provider, keyPath: nil, completionHandler: completionHandler)
    }
    
    override public func execute() {
        
        guard let providerData = providerOperation.response else {
            return
        }
        
        do {
            if let json = providerData.value as? UnboxableDictionary, let keyPath = keyPath {
                
                let unboxed: [UnboxableType] = try unbox(dictionary: json, atKey: keyPath)
                response = DataResponse(inputResponse: providerData, result: Result.success(unboxed))
                completionHandler?(response!)
                
            } else if let json = providerData.value as? [UnboxableDictionary] {
                
                let unboxed: [UnboxableType] = try unbox(dictionaries: json)
                response = DataResponse(inputResponse: providerData, result: Result.success(unboxed))
                completionHandler?(response!)
                
            } else {
                throw ParsingError.notParsable
            }
            
        } catch {
            response = DataResponse(inputResponse: providerData, result: Result.failure(error))
            completionHandler?(response!)
        }
        
    }
    
}

