//
//  DataResponse+MPLConversion.swift
//  MPOLKit
//
//  Created by Herli Halim on 8/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Alamofire

internal extension DataResponse {
    public func toDefaultDataResponse() -> DefaultDataResponse {
        return DefaultDataResponse(request: self.request, response: self.response, data: self.data, error: self.error, timeline: self.timeline, metrics: self.metrics)
    }
}

