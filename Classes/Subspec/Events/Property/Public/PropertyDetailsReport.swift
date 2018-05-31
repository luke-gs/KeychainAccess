//
//  PropertyDetailsReport.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public struct PropertyDetailsReport {
    public var property: Property?
    public var details: [String: String] = [:]
    public var involvements: [String]?
    public var media: [MediaAsset]?
}
