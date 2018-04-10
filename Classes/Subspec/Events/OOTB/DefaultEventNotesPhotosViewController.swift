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
        
        sidebarItem.regularTitle = "Notes and Photos"
        sidebarItem.compactTitle = "Notes and Photos"
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.attachment)!
        sidebarItem.color = (report?.evaluator.isComplete ?? false) ? .midGreen : .red
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
    
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        report?.viewed = true
    }
    
    override open func construct(builder: FormBuilder) {
        builder.title = "Notes and Photos"
        builder.forceLinearLayout = true
        
        builder += HeaderFormItem(text: "GENERAL")
        
        builder += TextFieldFormItem(title: "Operation Name", text: report?.operationName).onValueChanged { value in
            self.report?.operationName = value
        }
        
        builder += HeaderFormItem(text: "SUMMARY / NOTES").actionButton(title: "USE TEMPLATE", handler: { _ in })
        
        builder += TextFieldFormItem(title: "Free Text", text: report?.freeText).onValueChanged { value in
            self.report?.freeText = value
        }
    }
    
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = evaluator.isComplete == true ? .midGreen : .red
    }
}


public class DefaultNotesPhotosReport: Reportable {
    
    var viewed: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .viewed)
        }
    }
    
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
        if let event = event { evaluator.addObserver(event) }
        evaluator.registerKey(.viewed) {
            return self.viewed
        }
    }
    
    // Codable
    public static var supportsSecureCoding: Bool = true
    private enum Coding: String {
        case operationName
        case freeText
    }


    public required init?(coder aDecoder: NSCoder) {
        operationName = aDecoder.decodeObject(of: NSString.self, forKey: Coding.operationName.rawValue) as String?
        freeText = aDecoder.decodeObject(of: NSString.self, forKey: Coding.freeText.rawValue) as String?
    }


    public func encode(with aCoder: NSCoder) {
        aCoder.encode(operationName, forKey: Coding.operationName.rawValue)
        aCoder.encode(freeText, forKey: Coding.freeText.rawValue)
    }
    
    // Evaluation
    
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }
}
