//
//  EvaluationObserverable.swift
//  MPOLKit
//
//  Created by QHMW64 on 30/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol EvaluationObserverable: class {
    func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool)
}
