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
    
    private let matcher: NSRegularExpression
    private let trimCharacterSet: CharacterSet
    
    private static let toBeEscaped = ":/?&=;+!@#$()',*" as CFString
    
    public init() {
        matcher = try! NSRegularExpression(pattern: "\\{.+?\\}")
        trimCharacterSet = CharacterSet(charactersIn: "{}")
    }
    
    public func urlPathWith(template: String, parameters: [String: Any]) throws -> (path: String, parameters: [String: Any]) {
        
        var outputParameters = parameters
        var outputPath: String = ""
        
        // Swift 4 will have a nicer string API
        let templateString = template as NSString
        let templateLength = template.characters.count
        var lastRange = NSMakeRange(0, 0)
        
        var error: URLQueryBuilderError?
        
        matcher.enumerateMatches(in: template, options: [], range: NSMakeRange(0, templateLength)) { (result, flags, stop) in
            
            guard let result = result else {
                return
            }
            
            let token = templateString.substring(with: result.range) as NSString
            let key = token.trimmingCharacters(in: trimCharacterSet)
            
            if let value = outputParameters[key],
                let replacementValue = CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, String(describing: value) as CFString, type(of: self).toBeEscaped) {
                
                outputParameters.removeValue(forKey: key)
                let lastIndex = lastRange.location + lastRange.length
                outputPath.append(templateString.substring(with: NSMakeRange(lastIndex, result.range.location - lastIndex)))
                outputPath.append(replacementValue as String)
                lastRange = result.range
                
            } else {
                stop.pointee = ObjCBool(true)
                error = URLQueryBuilderError.valueNotFound(key: key, parameters: parameters)
            }
        }
        
        if let error = error {
            throw error
        }
        
        let lastIndex = lastRange.location + lastRange.length;
        if (lastIndex < templateLength) {
            let remainder = templateString.substring(with: NSMakeRange(lastIndex, templateLength - lastIndex))
            outputPath.append(remainder)
        }
        
        return (path: outputPath, parameters: outputParameters)
    }
    
}
