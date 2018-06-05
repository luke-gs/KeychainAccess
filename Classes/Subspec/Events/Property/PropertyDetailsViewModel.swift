//
//  PropertyDetailsViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public class PropertyDetailsViewModel {
    
    public var report = PropertyDetailsReport()
    public var completion: ((PropertyDetailsReport) -> ())?
    let involvements: [String]
    let properties: [Property]

    public var plugins: [FormBuilderPlugin]?

    public init(properties: [Property], involvements: [String], report: PropertyDetailsReport? = nil) {
        self.involvements = involvements
        self.properties = properties

        if let report = report {
            self.report = PropertyDetailsReport(copyingReport: report)
        }
    }

    public func updateDetails(with property: Property) {
        report.property = property
        report.involvements = nil
        let keys = property.detailNames?.compactMap{$0.title}
        guard let validKeys = keys else { return }
        let values = Array(repeating: "", count: validKeys.count)
        report.details = Dictionary(uniqueKeysWithValues: zip(validKeys, values))
    }
}


