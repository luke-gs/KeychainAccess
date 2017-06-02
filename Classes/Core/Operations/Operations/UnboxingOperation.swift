//
//  UnboxingOperation.swift
//  MPOLKit
//
//  Created by Herli Halim on 18/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import Alamofire

public extension DataResponse {
    
    public init(inputResponse: DataResponse<Any>, result: Result<Value>) {
        self.init(request: inputResponse.request, response: inputResponse.response, data: inputResponse.data, result: result, timeline: inputResponse.timeline)
    }
    
}

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
            completionHandler?(response!)
            
        } catch {
            response = DataResponse(inputResponse: providerData, result: Result.failure(error))
            completionHandler?(response!)
        }
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

