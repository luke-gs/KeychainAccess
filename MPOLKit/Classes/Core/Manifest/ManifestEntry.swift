//
//  ManifestEntry.swift
//  VCom
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
    
}
