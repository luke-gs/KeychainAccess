//
//  URLQueryBuilder.swift
//  MPOLKit
//
//  Created by Herli Halim on 9/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

final public class URLQueryBuilder {

    public enum URLQueryBuilderError: Error {
        case valueNotFound(key: String, parameters: [String: Any])
    }

    private let matcher = try! NSRegularExpression(pattern: "\\{.+?\\}")
    private let trimCharacterSet = CharacterSet(charactersIn: "{}")

    private static let toBeEscaped = ":/?&=;+!@#$()',*" as CFString

    public func urlPathWith(template: String, parameters: [String: Any]) throws -> (path: String, parameters: [String: Any]) {

        var outputParameters = parameters
        var outputPath: String = ""

        let templateLength = template.count

        var lastIndex = template.startIndex

        var error: URLQueryBuilderError?

        matcher.enumerateMatches(in: template, options: [], range: NSMakeRange(0, templateLength)) { (result, flags, stop) in

            guard let result = result, let resultRange = Range(result.range, in: template) else {
                return
            }

            let token = template[resultRange]
            let key = token.trimmingCharacters(in: trimCharacterSet)

            if let value = outputParameters[key],
                let replacementValue = CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, String(describing: value) as CFString, type(of: self).toBeEscaped) {

                outputParameters.removeValue(forKey: key)

                let upperBound = template.index(lastIndex, offsetBy: template.distance(from: lastIndex, to: resultRange.lowerBound))

                let path = String(template[lastIndex..<upperBound])

                outputPath.append(path)
                outputPath.append(replacementValue as String)

                lastIndex = resultRange.upperBound

            } else {
                stop.pointee = ObjCBool(true)
                error = URLQueryBuilderError.valueNotFound(key: key, parameters: parameters)
            }
        }

        if let error = error {
            throw error
        }

        let remainingLength = template.distance(from: lastIndex, to: template.endIndex)
        if (remainingLength > 0) {
            let remainder = String(template[lastIndex...])
            outputPath.append(remainder)
        }

        return (path: outputPath, parameters: outputParameters)
    }

    public init() {
    }

}
