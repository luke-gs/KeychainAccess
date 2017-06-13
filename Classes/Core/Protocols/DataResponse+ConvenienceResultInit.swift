//
//  DataResponse+ConvenienceResultInit.swift
//  MPOLKit
//
//  Created by Herli Halim on 2/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Alamofire

extension DataResponse {
    
    init(inputResponse: DataResponse<Any>, result: Result<Value>) {
        self.init(request: inputResponse.request, response: inputResponse.response, data: inputResponse.data, result: result, timeline: inputResponse.timeline)
    }
    
}
