//
//  Event.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 16/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

public protocol Reportable: class, Codable {
    weak var event: Event? { get set }
    init(event: Event)
}

final public class Event: Codable {

    public var relationId: String
    public var relationType: String = "Event"

    private(set) public var reports: [Reportable] = [Reportable]()

    public init() {
        relationId = UUID().uuidString
    }
    
    // Codable stuff begins
    
    public init(from: Decoder) throws {
        let container = try from.container(keyedBy: Keys.self)
        relationId = try container.decode(String.self, forKey: .relationId)
        relationType = try container.decode(String.self, forKey: .relationType)
        reports = try container.decode([Reportable].self, forKey: .reports)
    }
    
    public func encode(to: Encoder) throws {
        var container = to.container(keyedBy: Keys.self)
        try container.encode(relationId, forKey: .relationId)
        try container.encode(relationType, forKey: .relationType)
        try container.encode(reports, forKey: .reports)
    }
    
    enum Keys: String, CodingKey {
        case relationId = "relationId"
        case relationType = "relationType"
        case reports = "reports"
    }
    
    // Codable stuff ends

    public func add(reports: [Reportable]) {
        self.reports.append(contentsOf: reports)
    }

    public func add(report: Reportable) {
        self.reports.append(report)
    }
    
    
}
