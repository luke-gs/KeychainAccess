//
//  Whereabouts.swift
//  MPOLKit
//
//  Created by Herli Halim on 21/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import MPOLKit

private let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

open class Whereabouts: Event {
    
    open var requestingMemberID: String?
    open var notifyMemberName: String?
    open var notifyMemberDescription: String?
    
    // Other remarks probably will have similar format. Consider consolidating them.
    open var remarks: [WhereaboutsRemark]?
    
    open var reportDate: Date?
    open var action: String?
    open var reasonRequired: String?
    
    public required init(unboxer: Unboxer) throws {
        try super.init(unboxer: unboxer)
        
        requestingMemberID = unboxer.unbox(key: "requestingMemberId")
        notifyMemberName = unboxer.unbox(key: "notifyMemberName")
        notifyMemberDescription = unboxer.unbox(key: "notifyMemberDescription")
        
        remarks = unboxer.unbox(key: "remarks")
        
        reportDate = unboxer.unbox(key: "reportDateTime", formatter: dateTransformer)
        action = unboxer.unbox(key: "action")
        reasonRequired = unboxer.unbox(key: "reasonRequired")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
    
    public required init(id: String) {
        super.init(id: id)
    }
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        MPLUnimplemented()
    }
}

open class WhereaboutsRemark: NSObject, Serialisable {
    
    open var reportDate: Date?
    open var text: String?
    open var action: String?
    
    override public init() {
        super.init()
    }
        
    public required init(unboxer: Unboxer) throws {
        reportDate = unboxer.unbox(key: "reportDate", formatter: dateTransformer)
        text = unboxer.unbox(key: "text")
        action = unboxer.unbox(key: "action")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
    
    open func encode(with aCoder: NSCoder) {
        MPLUnimplemented()
    }
    
    open static var supportsSecureCoding: Bool {
        return true
    }
}
