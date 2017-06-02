//
//  UnboxingOperation.swift
//  MPOLKit
//
//  Created by Herli Halim on 18/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import Alamofire

open class DataResponseChainableOperation<Input: HasDataResponse, Output>: Operation, HasDataResponse, DataResponseOperationChainable where Input: Operation {
    
    public typealias DataResponseProviderType = Input
    public typealias DataResponseResultType = Output

    open let completionHandler: ((DataResponse<Output>) -> Void)?
    
    open let providerOperation: DataResponseProviderType
    
    open var response: DataResponse<Output>?
    
    public required init(provider: DataResponseProviderType, completionHandler: ((DataResponse<Output>) -> Void)?) {
        self.completionHandler = completionHandler
        self.providerOperation = provider
    }
    
    override open func execute() {
        super.execute()
    }
}

public class UnboxingOperation<UnboxableType: Unboxable>: DataResponseChainableOperation<URLJSONRequestOperation, UnboxableType> {
    
    public let keyPath: String?
    
    public init(provider: URLJSONRequestOperation, keyPath: String?, completionHandler: ((DataResponse<UnboxableType>) -> Void)?) {
        self.keyPath = keyPath
        super.init(provider: provider, completionHandler: completionHandler)
    }
    
    public required convenience init(provider: URLJSONRequestOperation, completionHandler: ((DataResponse<UnboxableType>) -> Void)?) {
        self.init(provider: provider, keyPath: nil, completionHandler: completionHandler)
    }

    override public func execute() {
        
        guard let providerData = providerOperation.response else {
            
            // Throw error here, maybe?
            
            return
        }
        
        do {
            if let json = providerData.value as? UnboxableDictionary {

                let unboxed: UnboxableType
                if let keyPath = keyPath {
                    unboxed = try unbox(dictionary: json, atKey: keyPath)
                } else {
                    unboxed = try unbox(dictionary: json)
                }
                let response = DataResponse<UnboxableType>(request: providerData.request, response: providerData.response, data: providerData.data, result: Result.success(unboxed), timeline: providerData.timeline)
                
                self.response = response
                
                completionHandler?(response)
            } else {
                // Throw error here, maybe?
            }
        } catch {
            let response = DataResponse<UnboxableType>(request: providerData.request, response: providerData.response, data: providerData.data, result: Result.failure(error), timeline: providerData.timeline)
            
            self.response = response
            
            completionHandler?(response)
        }

        let response = DataResponse<UnboxableType>(request: providerData.request, response: providerData.response, data: providerData.data, result: Result.failure(ParsingError.notParsable), timeline: providerData.timeline)
        
        self.response = response
        
        completionHandler?(response)
    }
}

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
            
            // Throw error here, maybe?
            return
        }
        
        do {
            if let json = providerData.value as? UnboxableDictionary, let keyPath = keyPath {
                
                let unboxed: [UnboxableType] = try unbox(dictionary: json, atKey: keyPath)
      
                let response = DataResponse<[UnboxableType]>(request: providerData.request, response: providerData.response, data: providerData.data, result: Result.success(unboxed), timeline: providerData.timeline)
                
                self.response = response
                
                completionHandler?(response)
            } else {
                // Throw error here, maybe?
            }
        } catch {
            let response = DataResponse<[UnboxableType]>(request: providerData.request, response: providerData.response, data: providerData.data, result: Result.failure(error), timeline: providerData.timeline)
            
            self.response = response
            
            completionHandler?(response)
        }
        
        let response = DataResponse<[UnboxableType]>(request: providerData.request, response: providerData.response, data: providerData.data, result: Result.failure(ParsingError.notParsable), timeline: providerData.timeline)
        
        self.response = response
        
        completionHandler?(response)
    }

}

