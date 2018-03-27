//
//  AppURLNavigator.swift
//  MPOLKit
//
//  Created by Herli Halim on 26/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import UIKit.UIApplication

// Imported to use `ParameterEncoding`
import Alamofire

public typealias AppURLNavigatorHandler = (_ urlString: String, _ values: [String: String]) -> Bool

open class AppURLNavigator {

    private var routerHandlerRegister: [String: AppURLNavigatorHandler] = [:]

    public init() {
        
    }

    open func open(_ scheme: String, host: String? = nil, path: String? = nil, parameters: [String: Any]? = nil,  completionHandler completion: ((Bool) -> Void)? = nil) throws {

        let components = routingInfoURLComponents(from: scheme, host: host, path: path)

        guard let url = components.url else {
            throw AppURLNavigatorError.invalidURLParameter
        }

        let request = URLRequest(url: url)

        let encodedURLRequest = try URLEncoding.default.encode(request, with: parameters)

        guard let encodedURL = encodedURLRequest.url else {
            throw AppURLNavigatorError.invalidURLParameter
        }

        UIApplication.shared.open(encodedURL, options: [:], completionHandler: completion)
    }

    open func register(_ scheme: String, host: String? = nil, path: String, handler: @escaping AppURLNavigatorHandler) throws {

        let components = routingInfoURLComponents(from: scheme, host: host, path: path)
        guard let pattern = components.url?.absoluteString else {
            throw AppURLNavigatorError.invalidURLParameter
        }

        routerHandlerRegister[pattern] = handler
    }

    open func canHandle(_ url: URL) -> Bool {
        return handler(for: url)?.1 != nil
    }

    open func handle(_ url: URL) -> Bool {

        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), let handler = handler(for: url) else {
            return false
        }

        var values: [String: String] = [:]
        if let queryItems = urlComponents.queryItems {
            queryItems.forEach {
                values[$0.name] = $0.value
            }
        }

        let pattern = handler.0
        return handler.1(pattern, values)
    }

    // MARK: - Private

    private func routingInfoURLComponents(from scheme: String?, host: String?, path: String?) -> URLComponents {

        var components = URLComponents()
        components.scheme = scheme
        components.host = host

        if let path = path {
            let normalisedPath: String
            if !path.hasPrefix("/") {
                normalisedPath = "/".appending(path)

            } else {
                normalisedPath = path
            }
            components.path = normalisedPath
        }

        return components
    }

    // Naming is hard, so anonymous tuple it is.
    private func handler(for url: URL) -> (String, AppURLNavigatorHandler)? {

        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }

        let checkedComponents = routingInfoURLComponents(from: urlComponents.scheme, host: urlComponents.host, path: urlComponents.path)

        if let pattern = checkedComponents.url?.absoluteString, let handler = routerHandlerRegister[pattern] {
            return (pattern, handler)
        } else {
            return nil
        }

    }

}

public enum AppURLNavigatorError: Error {
    case invalidURLParameter
}
