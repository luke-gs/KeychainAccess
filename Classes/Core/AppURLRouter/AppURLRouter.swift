//
//  AppURLRouter.swift
//  MPOLKit
//
//  Created by Herli Halim on 26/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public typealias AppURLRouterHandler = (_ urlString: String, _ values: [String: Any]) -> Bool

open class AppURLRouter {

    private var routerHandlerRegister: [String: AppURLRouterHandler] = [:]

    public init() {
        
    }

    open func register(_ scheme: String, host: String? = nil, path: String, handler: @escaping AppURLRouterHandler) {

        let components = routingInfoURLComponents(from: scheme, host: host, path: path)
        let pattern = components.url!.absoluteString

        routerHandlerRegister[pattern] = handler
    }

    open func canHandle(_ url: URL) -> Bool {
        return handler(for: url)?.1 != nil
    }

    open func handle(_ url: URL) -> Bool {

        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), let handler = handler(for: url) else {
            return false
        }

        var values: [String: Any] = [:]
        if let queryItems = urlComponents.queryItems {
            queryItems.forEach {
                values[$0.name] = $0.value
            }
        }

        let pattern = handler.0
        return handler.1(pattern, values)
    }

    private func routingInfoURLComponents(from scheme: String?, host: String?, path: String) -> URLComponents {
        var normalisedPath = path
        if !normalisedPath.hasPrefix("/") {
            normalisedPath = "/".appending(path)
        }

        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = normalisedPath

        return components
    }

    // Naming is hard, so anonymous tuple it is.
    private func handler(for url: URL) -> (String, AppURLRouterHandler)? {

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
