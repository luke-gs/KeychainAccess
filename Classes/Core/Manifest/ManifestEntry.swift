//
//  ManifestEntry.swift
//  MPOLKit
//
//  Created by Rod Brown on 28/10/16.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import CoreData

public class ManifestEntry: NSManagedObject {
    
    private var _hasFetchedAdditionalDetails: Bool = false
    private var _additionalDetails: [String: Any]?
    
    public var additionalDetails: [String: Any]? {
        get {
            if _hasFetchedAdditionalDetails == false {
                if let data = additionalData?.data(using: .utf8) {
                    if let decodedObject = try? JSONSerialization.jsonObject(with: data) {
                        _additionalDetails = decodedObject as? [String: Any]
                    }
                    _hasFetchedAdditionalDetails = true
                }
            }
            return _additionalDetails
        }
        set {
            _hasFetchedAdditionalDetails = true
            if let newValue = newValue,
                let newData = try? JSONSerialization.data(withJSONObject: newValue),
                let json = String(data: newData, encoding: .utf8) {
                additionalData     = json
                _additionalDetails = newValue
            } else {
                _additionalDetails = nil
                additionalData     = nil
            }
        }
    }
    
    public override func willTurnIntoFault() {
        _hasFetchedAdditionalDetails = false
        _additionalDetails = nil
    }
    
    public func archived() -> ArchivedManifestEntry {
        return ArchivedManifestEntry(entry: self)
    }
    
}

// Convenience extension for getting manifest info from array
extension Array where Element == ManifestEntry {

    // Get all manifest item values as an array, commonly used for drop downs
    public func rawValues() -> [String] {
        return self.compactMap { return $0.rawValue }
    }

    // Get all manifest entries keyed by their unique rawValue, for fast lookup
    public func rawValueDict() -> [String: ManifestEntry] {
        var result: [String: ManifestEntry] = [:]
        for item in self {
            if let value = item.rawValue {
                result[value] = item
            }
        }
        return result
    }
}
