//
//  PropertyDetailsReport.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}

open class PropertyDetailsReport: Reportable {

    public weak var event: Event?
    public weak var incident: Incident?
    private(set) public var evaluator: Evaluator = Evaluator()

    //TODO: Map from property types
    var type: String?
    var subtype: String?
    var details: [String: String]?
    var involvements: [String]?

    private var media: [MediaAsset]?

    var viewed: Bool = false {
    	didSet {
            evaluator.updateEvaluation(for: .viewed)
    	}
    }

    public required init(event: Event, incident: Incident?) {
        self.event = event
        self.incident = incident
        commonInit()
    }

    private func commonInit() {
        if let event = event {
            evaluator.addObserver(event)
        }
        if let incident = incident {
            evaluator.addObserver(incident)
        }

        evaluator.registerKey(.viewed) {
            return self.viewed
        }
    }

    // Coding
    public static var supportsSecureCoding: Bool = true
    private enum Coding: String {
        case incidents
    }

    public func encode(with aCoder: NSCoder) { }
    public required init?(coder aDecoder: NSCoder) {
    	commonInit()
    }

    // Evaluation
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }
}
