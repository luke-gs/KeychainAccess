//
//  APIManagerError.swift
//  Alamofire
//
//  Created by Herli Halim on 8/8/17.
//

import Foundation
import Alamofire

public struct APIManagerError: Error {
    let underlyingError: Error
    let response: DefaultDataResponse
}
