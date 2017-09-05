//
//  NetworkLoggingPlugin.swift
//  MPOLKit
//
//  Created by QHMW64 on 4/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import Alamofire

public struct NetworkLoggerConfiguration {
    var showMetrics: Bool

    public init(showMetrics: Bool = true) {
        self.showMetrics = showMetrics
    }
}

open class NetworkLoggingPlugin: PluginType {

    private var requests: Set<URLRequest> = []
    private let logger: Logger
    private let configurations: NetworkLoggerConfiguration

    public init(logger: Logger = Logger(loggers: [FileLogger(), ConsoleLogger()]), configurations: NetworkLoggerConfiguration = NetworkLoggerConfiguration()) {
        self.logger = logger
        self.configurations = configurations
    }

    public func willSend(_ request: Request) {

        let log = formattedOutput(
            request: request.request,
            headers: request.request?.allHTTPHeaderFields,
            data: request.request?.httpBody,
            result: (request.response?.statusCode, ""))
        logger.log(text: log)

        if let urlRequest = request.request {
            self.requests.insert(urlRequest)
        }
    }

    public func didReceiveResponse<T>(_ response: DataResponse<T>) {
        let log = formattedOutput(
            request: response.request,
            headers: response.response?.allHeaderFields,
            data: response.data,
            result: (response.response?.statusCode, response.result.description),
            metrics: response.metrics,
            error: response.error)

        logger.log(text: log)

        if let request = response.request {
            requests.remove(request)
        }
    }

    private func formattedOutput(request: URLRequest?,
                             headers: [AnyHashable: Any]?,
                             data: Data?,
                             result: (code: Int?, value: String)? = nil,
                             metrics: URLSessionTaskMetrics? = nil,
                             error: Error? = nil) -> String {

        typealias StringComponents = (key: String, value: String)

        let printOptions: JSONSerialization.WritingOptions = (headers?["Content-Type"] as? String)?.contains("application/json") == true ? [.prettyPrinted] : []

        var components: [StringComponents] = []

        // Result formatting
        if let result = result, !result.value.isEmpty {
            components.append(("Log Type: ", "Response"))
            if let code = result.code {
                components.append(("Response: ", "\(code)" + " - " + result.value))
            } else {
                components.append(("Response: ", result.value))
            }
        } else {
            components.append(("Log Type: ", "Request"))
        }
        
        components.append(("Method: ", request?.httpMethod ?? "{ }"))
        components.append(("Headers: ", headers?.prettyPrinted() ?? "{ }"))
        components.append(("Request: ", request?.description ?? "{ }"))

        if let metrics = metrics, configurations.showMetrics {
            components.append(("Metrics: ", metrics.prettyPrinted()))
        }

        // Body formatting
        if let data = data {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let prettyPrinted = try JSONSerialization.data(withJSONObject: json, options: printOptions)
                components.append(("Body: ", String(data: prettyPrinted, encoding: .utf8) ?? "{ }"))

            } catch {
                components.append(("Body: ", String(data: data, encoding: .utf8) ?? "{ }"))
            }
        }

        if let error = error {
            let error = APIManager.shared.configuration.errorMapper?.mappedError(from: error)
            components.append(("Localised error: ", error?.localizedDescription ?? "-"))
        }

        var result: String = ""
        for component in components {
            result += component.key + component.value + "\n"
        }

        let divider = "-----------------------------------------------------------------------------------\n"
        return divider + result + divider
    }
}

/// Helper methods to format the responses into readable formats

private extension Collection {

    /// Convert self to JSON String.
    /// - Returns: Returns the JSON as String or empty string if error while parsing.
    func prettyPrinted() -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
            guard let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) else {
                return "{}"
            }
            return jsonString
        } catch {
            return "{}"
        }
    }
}

private extension DateInterval {
    func formattedValues() -> [String: Any] {

        var dictionary: [String: Any] = [:]

        let timezone = TimeZone.current
        let options: ISO8601DateFormatter.Options = [ISO8601DateFormatter.Options.withFullDate, ISO8601DateFormatter.Options.withFullTime]

        dictionary["start date"] = ISO8601DateFormatter.string(from: start, timeZone: timezone, formatOptions: options)
        dictionary["end date"] = ISO8601DateFormatter.string(from: end, timeZone: timezone, formatOptions: options)
        dictionary["duration"] = "\(duration)"

        return dictionary
    }
}

private extension URLSessionTaskMetrics.ResourceFetchType {

    var displayValue: String {
        switch self {
        case .localCache: return "Local cache"
        case .networkLoad: return "Network load"
        case .serverPush: return "Server push"
        case .unknown: return "Unknown"
        }
    }
}

private extension URLSessionTaskMetrics {
    func prettyPrinted() -> String {

        let taskIntervalDictionary: [String: Any] = taskInterval.formattedValues()
        var dictionary: [String: Any] = [:]
        if let firstMetric = transactionMetrics.first {

            let timezone = TimeZone.current
            let options: ISO8601DateFormatter.Options = [ISO8601DateFormatter.Options.withFullDate, ISO8601DateFormatter.Options.withFullTime]

            if let fetchStartDate = firstMetric.fetchStartDate {
                dictionary["Fetch start date"] = ISO8601DateFormatter.string(from: fetchStartDate, timeZone: timezone, formatOptions: options)
            }
            if let requestStartDate = firstMetric.requestStartDate {
                dictionary["Request start date"] = ISO8601DateFormatter.string(from: requestStartDate, timeZone: timezone, formatOptions: options)
            }
            if let requestEndDate = firstMetric.requestEndDate {
                dictionary["Request end date"] = ISO8601DateFormatter.string(from: requestEndDate, timeZone: timezone, formatOptions: options)
            }
            if let responseStartDate = firstMetric.responseStartDate {
                dictionary["Response start date"] = ISO8601DateFormatter.string(from: responseStartDate, timeZone: timezone, formatOptions: options)
            }
            if let responseEndDate = firstMetric.responseEndDate {
                dictionary["Response end date"] = ISO8601DateFormatter.string(from: responseEndDate, timeZone: timezone, formatOptions: options)
            }

            dictionary["Proxy"] = "\(firstMetric.isProxyConnection)"
            dictionary["Reused connection"] = "\(firstMetric.isReusedConnection)"
            dictionary["Fetch type"] = firstMetric.resourceFetchType.displayValue
        }

        return ["Task interval": taskIntervalDictionary, "Details": dictionary].prettyPrinted()
    }
}
