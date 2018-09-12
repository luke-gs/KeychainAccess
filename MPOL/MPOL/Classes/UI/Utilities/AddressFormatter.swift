//
//  AddressFormatter.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

class AddressFormatter {
    
    enum Style {
        case short
        case long
    }
    
    /// Include common name in the result
    var includingName: Bool
    /// Each line separated by a new line or a space
    var withLines: Bool

    var style: Style
    
    init(includingName: Bool = true, withLines: Bool = false, style: Style = .long) {
        self.includingName = includingName
        self.withLines     = withLines
        self.style         = style
    }
    
    func formattedString(from address: Address) -> String? {
        switch style {
        case .short:
            return shortFormattedString(from: address)?.joined(separator: withLines ? "\n" : " ")
        case .long:
            return formattedLines(from: address)?.joined(separator: withLines ? "\n" : ", ")
        }
    }
    
    private func formattedLines(from address: Address) -> [String]? {
        var lines: [[String]] = []
        
        if includingName, let name = address.commonName, !name.isEmpty {
            lines.append([name])
        }
        
        var line: [String] = []
        if let unitNumber = address.unit?.ifNotEmpty() {
            line.append("Unit \(unitNumber)")
        }
        if let floor = address.floor?.ifNotEmpty() {
            line.append("Floor \(floor)")
        }
        if line.isEmpty == false {
            lines.append(line)
            line.removeAll()
        }
        
        if let streetNumber = address.streetNumberFirst?.ifNotEmpty() {
            line.append(streetNumber)
            
            if let streetNumberLast = address.streetNumberLast?.ifNotEmpty() {
                // FIXME: - This weird address line formatting stuff.
                line.removeAll()
                line.append("\(streetNumber)-\(streetNumberLast)")
            }
        }
        
        if let streetName = address.streetName?.ifNotEmpty() {
            line.append(streetName)
        }
        if let streetType = address.streetType?.ifNotEmpty() {
            line.append(streetType)
        }
        if let streetDirectional = address.streetDirectional?.ifNotEmpty() {
            line.append(streetDirectional)
        }
        if line.isEmpty == false {
            if includingName && address.commonName != nil && lines.isEmpty == false && line.joined(separator: " ") == address.commonName {
                _ = lines.remove(at: 0)
            }
            lines.append(line)
            line.removeAll()
        }
        
        if let suburb = address.suburb?.ifNotEmpty() {
            line.append(suburb)
        }
        if let city = address.county?.ifNotEmpty() {
            line.append(city)
        }
        if let state  = address.state?.ifNotEmpty() {
            line.append(state)
        }
        if let postCode = address.postcode?.ifNotEmpty() {
            line.append(postCode)
        }
        
        if line.isEmpty == false {
            lines.append(line)
        }
        if let country = address.country?.ifNotEmpty() {
            lines.append([country])
        }
        
        return lines.compactMap { $0.isEmpty == false ? $0.joined(separator: " ") : nil }
    }
    
    private func shortFormattedString(from address: Address) -> [String]? {
        var lines: [[String]] = []
        var line: [String] = []
        
        if includingName, let name = address.commonName, !name.isEmpty {
            lines.append([name])
        }
        
        if let unitNumber = address.unit?.ifNotEmpty() {
            line.append("Unit \(unitNumber)")
        }
        
        if let floor = address.floor?.ifNotEmpty() {
            line.append("Floor \(floor)")
        }
        
        if line.isEmpty == false {
            lines.append(line)
            line.removeAll()
        }
        
        if let streetNumber = address.streetNumberFirst?.ifNotEmpty() {
            line.append(streetNumber)
        }
        
        if let streetName = address.streetName?.ifNotEmpty() {
            line.append(streetName)
        }
        
        if let streetType = address.streetType?.ifNotEmpty() {
            line.append(streetType)
        }
        
        if let streetDirectional = address.streetDirectional?.ifNotEmpty() {
            line.append(streetDirectional)
        }
        
        if line.isEmpty == false {
            if lines.isEmpty == false && line.joined(separator: " ") == address.commonName {
                _ = lines.remove(at: 0)
            }
            lines.append(line)
            line.removeAll()
        }
        
        return lines.compactMap { $0.isEmpty == false ? $0.joined(separator: " ") : nil }
    }
}

extension AddressFormatter {
    @discardableResult
    func includingName(_ includingName: Bool) -> Self {
        self.includingName = includingName
        return self
    }
    
    @discardableResult
    func withLines(_ withLines: Bool) -> Self {
        self.withLines = withLines
        return self
    }
    
    @discardableResult
    func style(_ style: Style) -> Self {
        self.style = style
        return self
    }
}
