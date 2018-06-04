//
//  APIURLManager.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import Alamofire

class APIURLManager {

    private static let key = "PSCore_URL"
    private static let host = APP_HOST_URL
    private static let url = "https://\(APIURLManager.host)"

    public static var defaultURL: URLConvertible {
        return url
    }

    public static var customURL: URLConvertible? {
        let serverURL: String?
        if let customURL = UserDefaults.standard.value(forKey: APIURLManager.key) as? String {
            serverURL = customURL.ifNotEmpty()
        } else {
            serverURL = nil
        }

        guard let customURL = serverURL, let value = URL(string: customURL) else {
            return nil
        }

        return value
    }

    public static var serverURL: URLConvertible {

        let customURL = APIURLManager.customURL

        guard let serverURL = customURL, let value = try? serverURL.asURL() else {
            return url
        }

        return value
    }

}
