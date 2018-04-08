//
//  DefaultNotesAndAssetsReport.swift
//  MPOLKit
//
//  Created by QHMW64 on 23/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}

public class DefaultNotesAssetsReport: Reportable, MediaContainer {

    var viewed: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .viewed)
        }
    }

    var media: [Media] = []
    var operationName: String?
    var freeText: String?

    public weak var event: Event?
    public var evaluator: Evaluator = Evaluator()

    public required init(event: Event) {
        self.event = event
        commonInit()
    }

    // Codable

    public required init(from: Decoder) throws {
        let container = try from.container(keyedBy: Keys.self)
        operationName = try container.decode(String.self, forKey: .operationName)
        freeText = try container.decode(String.self, forKey: .freeText)
        media = try container.decode([Media].self, forKey: .media)

        commonInit()
    }

    public func commonInit() {
        if let event = self.event {
            evaluator.addObserver(event)
        }
        evaluator.registerKey(.viewed) {
            return self.viewed
        }
    }

    public func encode(to: Encoder) throws {
        var container = to.container(keyedBy: Keys.self)
        try container.encode(operationName, forKey: .operationName)
        try container.encode(freeText, forKey: .freeText)
        try container.encode(media, forKey: .media)
    }

    enum Keys: String, CodingKey {
        case operationName = "operationName"
        case freeText = "freeText"
        case media
    }

    // Media
    func add(_ media: [Media]) {
        media.forEach {
            if !self.media.contains($0) {
                self.media.append($0)
            }
        }
    }

    func remove(_ media: [Media]) {
        media.forEach { asset in
            if let index = self.media.index(where: { $0 == asset }) {
                self.media.remove(at: index)
            }
        }
    }

    // Evaluation

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }
}
