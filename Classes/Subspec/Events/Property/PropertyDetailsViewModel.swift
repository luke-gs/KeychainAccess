//
//  PropertyDetailsViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public class PropertyDetailsViewModel {
    
    public let title: String
    public let report: PropertyDetailsReport
	var loadingManagerState: LoadingStateManager.State {
		return .noContent
	}

    public required init(report: PropertyDetailsReport) {
        self.report = report
        self.title = "DefaultPropertyViewModel"
    }

    public var headerFormItemTitle: String {
        return title
    }

    public var tabColor: UIColor {
      return report.evaluator.isComplete ? .midGreen : .red
    }

    public func properties() -> [Property] {
        return props
    }

    public func involvements() -> [String] {
        return involvs
    }
}

//TODO: FIX THIS SHIT
private let props: [Property] = [
    Property(type: "General", subType: "Mobile Phone", detailNames: ["Make", "Model", "Model Year", "Serial Number"]),
    Property(type: "General", subType: "Clock"),
    Property(type: "General", subType: "Furniture", detailNames: ["Broken", "Colour"]),
    Property(type: "General", subType: "Electrical materials"),
    Property(type: "General", subType: "Laptop computer", detailNames: ["Make", "Model", "Serial Number"]),
    Property(type: "Drug", subType: "Oil - Cannabis", detailNames: ["Weight", "Type"]),
    Property(type: "Drug", subType: "Hashish - Cannabis", detailNames: ["Weight", "Type"]),
    Property(type: "Drug", subType: "LSD trips - Amphetamine/methylphetamine", detailNames: ["Quantity"]),
    Property(type: "Firearm", subType: "Air rifle", detailNames: ["Category", "Condition"]),
    Property(type: "Firearm", subType: "Shotgun - Category B", detailNames: ["Category", "Condition", "Loaded"]),
    Property(type: "Animal", subType: "Dog - Pitbull", detailNames: ["Colour", "Markings", "Gender"])
]

//TODO: FIX THIS SHIT
private let involvs: [String] = ["Broken", "Damaged", "Lost", "Killed"]
