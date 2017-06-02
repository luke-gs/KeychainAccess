//
//  DataResponseChainableOperation.swift
//  MPOLKit
//
//  Created by Herli Halim on 2/6/17.
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
