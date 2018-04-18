//
//  TrafficInfringementOffencesViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}
open class TrafficInfringementOffencesViewController: FormBuilderViewController, EvaluationObserverable {
    
    weak var report: TrafficInfringementOffencesReport?
    
    public init(report: Reportable?) {
        self.report = report as? TrafficInfringementOffencesReport
        super.init()
        report?.evaluator.addObserver(self)
        
        title = "Offences"
        
        sidebarItem.regularTitle = title
        sidebarItem.compactTitle = title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.alert)!
        sidebarItem.color = (report?.evaluator.isComplete ?? false) ? .midGreen : .red
        
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        //set initial state
        loadingManager.state = .noContent
        
        //text and image for "noContent" state
        loadingManager.noContentView.titleLabel.text = "No Offences Added"
        loadingManager.noContentView.subtitleLabel.text = "This report requires at least one offence"
        loadingManager.noContentView.imageView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.dialogAlert)
        loadingManager.noContentView.actionButton.setTitle("Add Offence", for: .normal)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        report?.viewed = true
    }
    
    override open func construct(builder: FormBuilder) {
        builder.title = title
        builder.forceLinearLayout = true
        
        builder += HeaderFormItem(text: "GENERAL")
        builder += HeaderFormItem(text: "SUMMARY / NOTES")
    }
    
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = evaluator.isComplete == true ? .midGreen : .red
    }
}
