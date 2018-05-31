//
//  PropertyDetailsViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public class PropertyDetailsViewModel {
    
    public var report = PropertyDetailsReport()
    let involvements: [String]
    let properties: [Property]

    var loadingManagerState: LoadingStateManager.State {
        return .noContent
    }

    public required init(properties: [Property], involvements: [String]) {
        self.involvements = involvements
        self.properties = properties
    }

    public func updateDetails(with property: Property) {
        report.property = property
        report.involvements = nil
        let keys = property.detailNames?.compactMap{$0.title}
        guard let validKeys = keys  else { return }
        let values = Array(repeating: "", count: validKeys.count)
        report.details = Dictionary(uniqueKeysWithValues: zip(validKeys, values))
    }
}
