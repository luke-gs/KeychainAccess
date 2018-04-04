//
//  AppURLNavigator.swift
//  MPOLKit
//
//  Created by Herli Halim on 26/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import UIKit.UIApplication

public typealias AppURLNavigatorHandler = (_ urlString: String, _ values: [String: Any]?) -> Bool

open class AppURLNavigator {

    private var routerHandlerRegister: [String: AppURLNavigatorHandler] = [:]

    public init() {
        
    }

    /// Attempts to open resource by passing in necessary information. Parameters that are passed in will
    /// be URL encoded.
    ///
    /// - Parameters:
    ///   - scheme, host, path: Components of URL to be used.
    ///   - parameters: The parameters to be passed in, they will be percent-escaped and as best possible translated to URL encoded query string components.
    ///   - completion: Completion handler that will be passed to the `UIApplication.open(_:options:completionHandler:)`
    /// - Throws: `AppURLNavigatorError`.invalidURLParameter if URL can't be constructed.
    open func open(_ scheme: String, host: String? = nil, path: String? = nil, parameters: [String: Any]? = nil,  completionHandler completion: ((Bool) -> Void)? = nil) throws {

        var components = routingInfoURLComponents(from: scheme, host: host, path: path)

        // Wrap parameters in internal dictionary,
        // with the parameter as JSON, represented as `String`
        if let parameters = parameters {
            do {
                let parametersData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                if let parameterString = String(data: parametersData, encoding: .utf8) {
                    components.queryItems = [URLQueryItem(name: "__wrapped", value: parameterString)]
                }
            } catch {
                throw AppURLNavigatorError.invalidURLParameter
            }
        }

        guard let url = components.url else {
            throw AppURLNavigatorError.invalidURLParameter
        }

        // On debug, print message to make sure that the url is whitelisted.
        // On production, well, the show must go on.
        assert(UIApplication.shared.canOpenURL(url), "Trying to open \(url), it's not whitelisted.")
        
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }


    /// Register a handler for a URL.
    ///
    /// - Parameters:
    ///   - scheme, host, path: Components of URL to be used.
    /// - Throws: `AppURLNavigatorError`.invalidURLParameter if URL can't be constructed.
    open func register(_ scheme: String, host: String? = nil, path: String, handler: @escaping AppURLNavigatorHandler) throws {

        let components = routingInfoURLComponents(from: scheme, host: host, path: path)
        guard let pattern = components.url?.absoluteString else {
            throw AppURLNavigatorError.invalidURLParameter
        }

        routerHandlerRegister[pattern] = handler
    }


    /// Checks whether the URL matches any registered `scheme, host and path`.
    /// This is usually used in `UIApplication.open(_:options:completionHandler:)` to quickly verify whether the URL could be handled.
    /// The `URL` is expected to be passed to next handler if this returns `false`.
    ///
    /// - Parameter url: The url to be checked.
    /// - Returns: `true` or `false` to indicate that url matches the scheme registered in this navigator.
    open func isRegistered(_ url: URL) -> Bool {
        return handler(for: url)?.1 != nil
    }


    /// Handle the URL using the registered handler.
    ///
    /// - Parameter url: The URL from `UIApplication.open(_:options:completionHandler)` to be handled.
    /// - Returns: `true` or `false` to indicate whether the URL is handled.
    open func handle(_ url: URL) -> Bool {

        guard let handler = handler(for: url) else {
            return false
        }

        let values = urlQueryParameters(from: url)

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

    private func urlQueryParameters(from url: URL) -> [String: Any]? {

        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryString = urlComponents.query else {
                return nil
        }

        var results: [String: Any] = [:]

        let components = queryString.components(separatedBy: "&")
        components.forEach {

            var parts = $0.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)

            if parts.count > 1,
                let key = urlDecodedString(from: String(parts[0])),
                let value: Any = urlDecodedString(from: String(parts[1])) {

                decode(key: key, value: value, into: &results)

            }
        }

        // Actual data is wrapped in a dictionary of ["__wrapped": [String: Any]]
        // where [String: Any] is actually a String, so convert it back.
        var parameters: [String: Any]?
        if let parametersAsString = results["__wrapped"] as? String,
            let data = parametersAsString.data(using: .utf8) {
            parameters = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
        }

        return parameters ?? [:]
    }

    // Only one level deep for now.
    private func decode(key: String, value: Any, into results: inout [String: Any]) {

        var currentKey = key
        var currentValue = value

        var isArray = false
        var isObject = false
        var subkey = ""

        if currentKey.contains("[") && currentKey.contains("]") {
            let slices = currentKey.split(separator: "[", maxSplits: 1)
            guard slices.count == 2 else {
                // Well, bye bye
                return
            }

            currentKey = String(slices[0])
            let contents = String(slices[1])

            // This is an array, array starts with `[` and ends with `]`
            if String(contents[contents.startIndex]) == "]" {
                isArray = true
            } else {
                subkey = String(contents.dropLast())
                isObject = true
            }

        }

        let existingValue = results[currentKey]

        if var existingArray = existingValue as? [Any] {
            existingArray.append(value)
            currentValue = existingArray
        } else if var existingDictionary = existingValue as? [String: Any] {
            existingDictionary[subkey] = value
            currentValue = existingDictionary
        } else if let existingValue = existingValue {
            currentValue = existingValue
        } else if isArray {
            currentValue = [currentValue]
        } else if isObject {
            currentValue = [subkey: currentValue]
        }
        results[currentKey] = currentValue

    }

    private func urlDecodedString(from urlString: String?) -> String? {
        guard let urlString = urlString else {
            return nil
        }

        var results = urlString
        results = results.replacingOccurrences(of: "+", with: " ")
        
        return (results as NSString).removingPercentEncoding
    }

}

public enum AppURLNavigatorError: Error {
    case invalidURLParameter
}

extension AppURLNavigator {

    public static var `default`: AppURLNavigator = {
        return AppURLNavigator()
    }()
    
}
