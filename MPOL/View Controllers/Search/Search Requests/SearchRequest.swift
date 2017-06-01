//
//  SearchRequest.swift
//  MPOL
//
//  Created by Rod Brown on 12/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

@objc(MPLSearchRequest)
class SearchRequest: NSObject, NSSecureCoding, NSCopying {
    
    static var supportsSecureCoding: Bool { return true }
    
    class var localizedDisplayName: String {
        return NSLocalizedString("Any Entity", comment: "")
    }
    
    var searchText: String? {
        didSet {
            if searchText == oldValue { return }
            
            let wasOldInvalid = oldValue?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty    ?? true
            let isInvalid     = searchText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
            
            if wasOldInvalid != isInvalid {
                validityDidChange()
            }
        }
    }
    
    private var cachedValidity = false
    
    required init(searchText: String? = nil) {
        self.searchText = searchText
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        searchText = aDecoder.decodeObject(of: NSString.self, forKey: #keyPath(searchText)) as String?
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(searchText, forKey: #keyPath(searchText))
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return type(of: self).init(searchText: self.searchText)
    }
    
    @objc dynamic var isValid: Bool {
        return searchText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true == false
    }
    
    func validityDidChange() {
        let isValid = self.isValid
        if isValid != cachedValidity {
            let key = #keyPath(SearchRequest.isValid)
            willChangeValue(forKey: key)
            didChangeValue(forKey: key)
            cachedValidity = isValid
        }
    }
    
    var localizedTitle: String? {
        return searchText
    }
    
    var localizedDescription: String {
        return type(of: self).localizedDisplayName
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let otherRequest = object as? SearchRequest else { return false }
        
        return type(of: otherRequest) == type(of: self).superclass() && searchText == otherRequest.searchText
    }
    
}


