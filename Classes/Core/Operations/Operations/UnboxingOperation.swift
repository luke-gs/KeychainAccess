//
//  UnboxingOperation.swift
//  MPOLKit
//
//  Created by Herli Halim on 18/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import Alamofire

public enum UnboxingResult<T> {
    case asObject(T)
    case asArray([T])
}

public class UnboxingOperation <UnboxableType: Unboxable> : Operation, DataResponseOperationChainable {
    
    public var completionHandler: ((DataResponse<UnboxingResult<UnboxableType>>) -> Void)?
    
    private let provider: HasDataResponse
    
    public required init<Provider: HasDataResponse>(provider: Provider, completionHandler: ((DataResponse<UnboxingResult<UnboxableType>>) -> Void)?) where Provider: Operation {
        
        self.provider = provider
        
        super.init()
        self.addDependency(provider)
    }
    
    override public func execute() {
        guard let providerData = provider.response else {
            return
        }
        
        let toBeParsed: Any?
        
        if let data = providerData.value as? Data {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                toBeParsed = json
            } catch {
                let response = DataResponse<UnboxingResult<UnboxableType>>(request: providerData.request, response: providerData.response, data: providerData.data, result: Result.failure(error), timeline: providerData.timeline)
                completionHandler?(response)
                
                return
            }
            
        } else {
            toBeParsed = providerData.value
        }
        
        do {
            
            if let json = toBeParsed as? UnboxableDictionary {
                let unboxed: UnboxableType = try unbox(dictionary: json)
                
                let value = DataResponse<UnboxingResult<UnboxableType>>(request: providerData.request, response: providerData.response, data: providerData.data, result: Result.success(.asObject(unboxed)), timeline: providerData.timeline)
                
                completionHandler?(value)
                
                return
                
            } else if let json = toBeParsed as? [UnboxableDictionary] {
                let unboxed: [UnboxableType] = try unbox(dictionaries: json)
                
                let value = DataResponse<UnboxingResult<UnboxableType>>(request: providerData.request, response: providerData.response, data: providerData.data, result: Result.success(.asArray(unboxed)), timeline: providerData.timeline)
                completionHandler?(value)
                
                return
            }
            
        } catch  {
            
            let response = DataResponse<UnboxingResult<UnboxableType>>(request: providerData.request, response: providerData.response, data: providerData.data, result: Result.failure(error), timeline: providerData.timeline)
            completionHandler?(response)
            
            return
        }
        
        let response = DataResponse<UnboxingResult<UnboxableType>>(request: providerData.request, response: providerData.response, data: providerData.data, result: Result.failure(ParsingError.notParsable), timeline: providerData.timeline)
        completionHandler?(response)
        
    }
    
}
