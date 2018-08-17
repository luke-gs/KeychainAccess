//
//  Evaluatable.swift
//  MPOLKit
//
//  Created by QHMW64 on 30/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol Evaluatable: EvaluationObserverable {
    var evaluator: Evaluator { get }
}
