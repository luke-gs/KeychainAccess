//
//  Event.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 16/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

public protocol Reportable: class, NSCoding {
    weak var event: Event? { get set }
    init(event: Event)
}

final public class Event: NSCoding {

    public var relationId: String
    public var relationType: String = "Event"

    private(set) public var reports: [Reportable] = [Reportable]()

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(relationId, forKey: "id")
        aCoder.encode(relationType, forKey: "relationType")
        aCoder.encode(reports, forKey: "reports")
    }

    public init?(coder aDecoder: NSCoder) {
        relationId = aDecoder.decodeObject(of: NSString.self, forKey: "id") as String!
        relationType = aDecoder.decodeObject(of: NSString.self, forKey: "relationType") as String!
        reports = aDecoder.decodeObject(of: NSArray.self, forKey: "reports") as! [Reportable]
    }

    public init() {
        relationId = UUID().uuidString
    }

    public func add(reports: [Reportable]) {
        self.reports.append(contentsOf: reports)
    }

    public func add(report: Reportable) {
        self.reports.append(report)
    }

    public func reportable(for reportableType: AnyClass) -> Reportable? {
        return self.reports.filter{type(of: $0) == reportableType}.first
    }
}

