//
//  OAuth2Error.swift
//  MPOLKit
//
//  Created by Herli Halim on 15/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public enum OAuth2Error: String, Error {

    case invalidState = "invalid_state"
    case invalidRequest = "invalid_request"
    case unauthorizedClient = "unauthorized_client"
    case accessDenied = "access_denied"
    case unsupportedResponseType = "unsupported_response_type"
    case invalidScope = "invalid_scope"
    case serverError = "server_error"
    case temporarilyUnavailable = "temporarilyUnavailable"


    public static var allCases: Set<OAuth2Error> = [ .invalidRequest, .unauthorizedClient, .accessDenied, .unsupportedResponseType, .invalidScope, .serverError, .temporarilyUnavailable ]

    public static var allErrorsString: Set<String> {
        let all = OAuth2Error.allCases
        return Set(all.map{ $0.rawValue })
    }

}
