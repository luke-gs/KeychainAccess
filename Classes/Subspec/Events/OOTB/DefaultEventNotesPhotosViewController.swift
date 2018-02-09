//
//  DefaultEventNotesPhotosViewController.swift
//  MPOLKit
//
//  Created by Kara Valentine on 9/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}

open class DefaultEventNotesPhotosViewController: FormBuilderViewController, EvaluationObserverable {
    
    weak var report: DefaultNotesPhotosReport?
    
    public init(report: Reportable?) {
        self.report = report as? DefaultNotesPhotosReport
        super.init()
        report?.evaluator.addObserver(self)
        
        // default evaluator behaviour - start false, become true on viewed
        try? report?.evaluator.addEvaluation(false, for: .viewed)
        
        sidebarItem.regularTitle = "Notes and Photos"
        sidebarItem.compactTitle = "Notes and Photos"
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.attachment)!
        sidebarItem.color = .red
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
    
    
    open override func viewDidAppear(_ animated: Bool) {
        // evaluator consults viewed handler on viewDidLoad
        report?.evaluator.updateEvaluation(for: .viewed)
    }
    
    override open func construct(builder: FormBuilder) {
        builder.title = "Notes and Photos"
        builder.forceLinearLayout = true
        
        builder += HeaderFormItem(text: "GENERAL")
        
        builder += TextFieldFormItem(title: "Operation Name")
        
        builder += HeaderFormItem(text: "SUMMARY / NOTES").actionButton(title: "USE TEMPLATE", handler: { _ in })
        
        builder += TextFieldFormItem(title: "Free Text")
    }
    
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = evaluator.isComplete == true ? .green : .red
    }
}


public class DefaultNotesPhotosReport: Reportable {
    
    var operationName: String?
    var freeText: String?
    
    public weak var event: Event?
    public var evaluator: Evaluator = Evaluator()
    
    public required init(event: Event) {
        self.event = event
        
        evaluator.addObserver(event)
        
        // evaluation of this key always returns true
        evaluator.registerKey(.viewed) {
            return true
        }
    }
    
    // Codable
    
    public required init(from: Decoder) throws {
        let container = try from.container(keyedBy: Keys.self)
        operationName = try container.decode(String.self, forKey: .operationName)
        freeText = try container.decode(String.self, forKey: .freeText)
    }
    
    public func encode(to: Encoder) throws {
        var container = to.container(keyedBy: Keys.self)
        try container.encode(operationName, forKey: .operationName)
        try container.encode(freeText, forKey: .freeText)
    }
    
    enum Keys: String, CodingKey {
        case operationName = "operationName"
        case freeText = "freeText"
    }
    
    // Evaluation
    
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }
}
