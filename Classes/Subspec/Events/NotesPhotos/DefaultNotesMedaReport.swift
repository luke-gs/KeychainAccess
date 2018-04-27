//
//  DefaultNotesMediaReport.swift
//  MPOLKit
//
//  Created by QHMW64 on 23/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}

public class DefaultNotesMediaReport: Reportable, MediaContainer {

    var viewed: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .viewed)
        }
    }

    var media: [Media] = []
    var operationName: String?
    var freeText: String?

    public weak var event: Event?
    public weak var incident: Incident?

    public var evaluator: Evaluator = Evaluator()

    public required init(event: Event) {
        self.event = event
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

    // Coding

    public static var supportsSecureCoding: Bool = true
    private enum Coding: String {
        case media
        case operationName
        case freeText
    }


    public required init?(coder aDecoder: NSCoder) {
        media = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.media.rawValue) as! [Media]
        operationName = aDecoder.decodeObject(of: NSString.self, forKey: Coding.operationName.rawValue) as String?
        freeText = aDecoder.decodeObject(of: NSString.self, forKey: Coding.freeText.rawValue) as String?
        commonInit()
    }


    public func encode(with aCoder: NSCoder) {
        aCoder.encode(media, forKey: Coding.media.rawValue)
        aCoder.encode(operationName, forKey: Coding.operationName.rawValue)
        aCoder.encode(freeText, forKey: Coding.freeText.rawValue)
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
