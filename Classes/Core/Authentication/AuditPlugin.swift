//
//  AuthenticationPlugin.swift
//  MPOLKit
//
//  Created by Valery Shorinov on 19/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class AuditPlugin: PluginType {
    
    static let auditSessionIdKey = "X-Session-ID"
    static let auditDeviceIdKey = "X-Device-ID"
    static let auditTransactionIdKey = "X-Transaction-ID"


    
    open func adapt(_ urlRequest: URLRequest) -> URLRequest {
        var adaptedRequest = urlRequest
        
        let session = UserSession.current
        
        adaptedRequest.addValue(session.sessionID, forHTTPHeaderField: AuditPlugin.auditSessionIdKey)
        adaptedRequest.addValue(UIDevice.current.identifierForVendor!.uuidString, forHTTPHeaderField: AuditPlugin.auditDeviceIdKey)
        
        // transaction ID

        return adaptedRequest
    }
    
}
