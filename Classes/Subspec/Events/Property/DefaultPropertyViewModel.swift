//
//  DefaultPropertyViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public class DefaultPropertyViewModel {
    
    public let title: String
    public let report: DefaultPropertyReport
	var loadingManagerState: LoadingStateManager.State {
		return .noContent
	}

    public required init(report: DefaultPropertyReport) {
        self.report = report
        self.title = "DefaultPropertyViewModel"
    }

    public var headerFormItemTitle: String {
        return title
    }

    public var tabColor: UIColor {
      return report.evaluator.isComplete ? .midGreen : .red
    }

    public func types() -> [String] {
        return Array(repeating: "Property Type", count: 10)
    }
    
    public func subtypes() -> [String] {
        return Array(repeating: "Sub Type", count: 10)
    }

    public func involvements() -> [String] {
        return Array(repeating: "Involvement", count: 10)
    }

    public func details() -> [String] {
        return Array(repeating: "Detail", count: 10)
    }
}
