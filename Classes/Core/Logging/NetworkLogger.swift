//
//  Logging.swift
//  Pods
//
//  Created by QHMW64 on 4/9/17.
//
//

import Foundation
import Alamofire

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

public struct MPOLLoggingConfigurations: LoggingConfigurations {
    var writeToFile: Bool

    init(writeToFile: Bool = true) {
        self.writeToFile = writeToFile
    }
}

protocol LoggingConfigurations {
    var writeToFile: Bool { get set }
}

public struct NetworkLogger {

    private let writeToFile: Bool

    init(configs: LoggingConfigurations) {
        self.writeToFile = configs.writeToFile

        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
            let divider = "-----------------------------------------------------------------------------------"
            print(divider + "\n" + "Logging to: \(documentsPath)" + "\n" + divider)
        }
    }

    typealias Headers = [AnyHashable: Any]
    typealias StringComponents = (key: String, value: String)
    typealias NetworkResponse = (code: Int?, result: String)

    func log<T>(response: DataResponse<T>) {

        let log = jsonPrinted(
            request: response.request,
            headers: response.response?.allHeaderFields,
            data: response.data,
            result: (response.response?.statusCode, response.result.description),
            metrics: response.metrics,
            error: response.error)
        print(log)
        DispatchQueue.global(qos: .background).async {
            self.write(text: log)
        }
    }

    func log(request: Alamofire.Request) {
        let log = jsonPrinted(
            request: request.request,
            headers: request.request?.allHTTPHeaderFields,
            data: request.request?.httpBody,
            result: (request.response?.statusCode, ""))
        print(log)
        DispatchQueue.global(qos: .background).async {
            self.write(text: log)
        }
    }

    private func jsonPrinted(request: URLRequest?,
                             headers: Headers?,
                             data: Data?,
                             result: NetworkResponse? = nil,
                             metrics: URLSessionTaskMetrics? = nil,
                             error: Error? = nil) -> String {

        let printOptions: JSONSerialization.WritingOptions = (headers?["Content-Type"] as? String)?.contains("application/json") == true ? [.prettyPrinted] : []

        var components: [StringComponents] = []

        components.append(("Headers: ", headers?.prettyPrinted() ?? "{ }"))
        components.append(("Request: ", request?.description ?? "{ }"))
        components.append(("Method: ", request?.httpMethod ?? "{ }"))
        components.append(("Metrics: ", metrics?.prettyPrinted() ?? "{ }"))

        // Result formatting
        if let result = result {
            if let code = result.code {
                components.append(("Result: ", "\(code)" + " - " + result.result))
            } else {
                components.append(("Result: ", result.result))
            }
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

    private func write(text: String) {
        let fileManager = FileManager.default
        let fileName = UUID().uuidString + ".txt"
        let networkLogPath = try? fileManager.url(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("Logs/Network")
        if !fileManager.fileExists(atPath: networkLogPath!.path) {
            do {
                try fileManager.createDirectory(atPath: networkLogPath!.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating directory.\nCause: \(error)")
            }
        }

        if let file = networkLogPath {
            if let handle = FileHandle(forWritingAtPath: file.appendingPathComponent(fileName).path) {
                handle.seekToEndOfFile()
                handle.write(text.data(using: .utf8)!)
                handle.closeFile()
            } else {
                try? text.data(using: .utf8)?.write(to: file.appendingPathComponent(fileName))
            }
        }
    }
}

/// Helper methods to format the responses into readable formats

private extension DateInterval {
    func formattedValues() -> [String: Any] {

        var dictionary: [String: Any] = [:]

        dictionary["start date"] = start.wrap(dateFormatter: DateFormatter.shortDate)
        dictionary["end date"] = end.wrap(dateFormatter: DateFormatter.shortDate)
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
            dictionary["Fetch start date"] = firstMetric.fetchStartDate?.wrap(dateFormatter: DateFormatter.longDateAndTime)
            dictionary["Request start date"] = firstMetric.requestStartDate?.wrap(dateFormatter: DateFormatter.longDateAndTime)
            dictionary["Request end date"] = firstMetric.requestEndDate?.wrap(dateFormatter: DateFormatter.longDateAndTime)
            dictionary["Response start date"] = firstMetric.responseStartDate?.wrap(dateFormatter: DateFormatter.longDateAndTime)
            dictionary["Response end date"] = firstMetric.responseEndDate?.wrap(dateFormatter: DateFormatter.longDateAndTime)

            dictionary["Proxy"] = "\(firstMetric.isProxyConnection)"
            dictionary["Reused connection"] = "\(firstMetric.isReusedConnection)"
            dictionary["Fetch type"] = firstMetric.resourceFetchType.displayValue
        }
        
        return ["Task interval": taskIntervalDictionary, "Details": dictionary].prettyPrinted()
    }
}
