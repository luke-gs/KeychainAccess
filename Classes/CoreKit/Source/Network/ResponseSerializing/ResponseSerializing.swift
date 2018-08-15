//
//  ResponseSerializing.swift
//  MPOLKit
//
//  Created by Herli Halim on 1/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Alamofire

public protocol ResponseSerializing {

    associatedtype ResultType

    func serializedResponse(from dataResponse: DataResponse<Data>) -> Result<ResultType>

}
