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
    var excludedHeaders: Set<String>
    var excludedPaths: Set<String>

    /// -----------------------------------------------------------------------------------------------
    /// Initialise a file logging configuration
    /// If the paths or keys are found, the values represented are replaced with a simple string
    /// "Secure content" - Allowing the request/response to still be useful in debuggging/logging
    ///
    /// - Parameters:
    ///   - showMetrics: Whether the logs should display the metrics of the request/response
    ///   - excludedHeaders: A set containing keys to be removed from the headers
    ///   - excludedPaths: The keys to match the urlRequests path components. Will be removed if found
    /// -----------------------------------------------------------------------------------------------
    public init(showMetrics: Bool = true,
                excludedHeaders: Set<String> = ["authorization", "Authorization"],
                excludedPaths: Set<String> = ["login", "access_token", "refresh_token", "id_token"]) {
        self.showMetrics = showMetrics
        self.excludedHeaders = excludedHeaders
        self.excludedPaths = excludedPaths
    }
}
/// -----------------------------------------------------------------------------------------------
/// The Network Logging Plugin for MPOLKit 
/// Contains an array of requests that it internally manages
/// A reference to the Logger that handles the logging process
/// Will format the request/response into readable format and then delegate the logging to the logger
/// -----------------------------------------------------------------------------------------------
open class NetworkLoggingPlugin: PluginType {

    private var requests: Set<URLRequest> = []
    private let logger: Logger
    private let configurations: NetworkLoggerConfiguration

    /// -----------------------------------------------------------------------------------------------
    /// Public initialiser for NetworkLoggingPlugin
    ///
    /// - Parameters:
    ///   - logger: The Logger responsible for logging the formatted output
    ///   - configurations: Certain confirgurations that can be applied to the formatted response 
    /// -----------------------------------------------------------------------------------------------
    public init(logger: Logger = Logger(loggers: [FileLogger(), ConsoleLogger()]), configurations: NetworkLoggerConfiguration = NetworkLoggerConfiguration()) {
        self.logger = logger
        self.configurations = configurations
    }

    /// -----------------------------------------------------------------------------------------------
    /// Called when the App will send through a request
    ///
    /// - Parameter request: The request that was performed (Output based on this request)
    /// -----------------------------------------------------------------------------------------------
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

    /// -----------------------------------------------------------------------------------------------
    /// When the application receives a response from a request that was made
    ///
    /// - Parameter response: The response to be processed
    /// -----------------------------------------------------------------------------------------------
    public func didReceiveResponse(_ response: DataResponse<Data>) {
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

    /// -----------------------------------------------------------------------------------------------
    /// Private function to handle the formatting of each network request/reponse
    ///
    /// - Parameters:
    ///   - request: The urlRequest of either the request or the response's orginal request
    ///   - headers: The headers contained in the response/request
    ///   - data: The body of the response/request
    ///   - result: Whether the reponse was successful (Contains the code and the formatted text)
    ///   - metrics: The internal metrics of the request or response
    ///   - error: Any error that was returned by the request/response
    /// - Returns: A string that has been formatted 
    /// -----------------------------------------------------------------------------------------------
    private func formattedOutput(request: URLRequest?,
                             headers: [AnyHashable: Any]?,
                             data: Data?,
                             result: (code: Int?, value: String)? = nil,
                             metrics: URLSessionTaskMetrics? = nil,
                             error: Error? = nil) -> String {

        typealias StringComponents = (key: String, value: String)

        let printOptions: JSONSerialization.WritingOptions = (headers?["Content-Type"] as? String)?.contains("application/json") == true ? [.prettyPrinted] : []

        // An array of [String: String] used to map titles and values
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

        // Filter out any excluded header keys present in the configurations
        var filteredHeaders: [AnyHashable: Any] = [:]
        headers?.forEach {
            filteredHeaders[$0.key] = !configurations.excludedHeaders.contains("\($0.key)") ? $0.value : "Secure content"
        }

        components.append(("Headers: ", filteredHeaders.prettyPrinted() ))
        components.append(("Request: ", request?.description ?? "{ }"))

        // Metrics may be nil or the configurations passed in may not require metrics
        if let metrics = metrics, configurations.showMetrics {
            components.append(("Metrics: ", metrics.prettyPrinted()))
        }

        // Body formatting
        if let data = data {

            let toBePrinted: String?

            do {
                // Serialise and de-seriablise into pretty printed strings if possible
                // Otherwise just print out the string representation of the body
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let filteredJSONBlob = filteredJSON(json)

                let toBePrintedData = try JSONSerialization.data(withJSONObject: filteredJSONBlob, options: printOptions)
                toBePrinted = String(data: toBePrintedData, encoding: .utf8)

            } catch {
                toBePrinted = shouldLog(request) == true ? String(data: data, encoding: .utf8) : "Secure content"
            }

            components.append(("Body: ", toBePrinted ?? "Empty body"))
        }

        if let error = error {
            let error = APIManager.shared.configuration.errorMapper?.mappedError(from: error)
            components.append(("Localised error: ", error?.localizedDescription ?? "-"))
        }

        var result = String()
        for component in components {
            result += component.key + component.value + "\n"
        }

        let divider = "-----------------------------------------------------------------------------------\n"
        return divider + result + divider
    }

    private func shouldLog(_ request: URLRequest?) -> Bool {
        for path in configurations.excludedPaths {
            if request?.url?.pathComponents.contains( where: { $0.localizedCaseInsensitiveCompare(path) == .orderedSame  } ) == true {
                return false
            }
        }

        return true
    }

    // Recursively go to the json and take things out of it.
    private func filteredJSON(_ json: Any) -> Any {

        if let json = json as? [String: Any] {

            var filteredJSON: [String: Any] = [:]
            json.forEach {
                filteredJSON[$0.key] = !configurations.excludedPaths.contains($0.key) ? $0.value : "Secure content"
            }
            return filteredJSON

        } else if let json = json as? [[String: Any]] {
            var filtered: [Any?] = []
            json.forEach {
                filtered.append(filteredJSON($0))
            }
            return filtered
        }

        return json
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

// MARK: - Formatting a date interval and its internal parameters
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

// MARK: - Formatting a ResourceFetchType into a string
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

// MARK: - Formatting the SessionTaskMetrics 
/// Only format certain properties of the metrics as some are irrrelevant to the NetworkLog readability
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
