//
//  EventEntityRelationshipsViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class EventEntityRelationshipsViewController: FormBuilderViewController, EvaluationObserverable {

    let viewModel: EventEntityRelationshipsViewModel

    public required init(viewModel: EventEntityRelationshipsViewModel) {
        self.viewModel = viewModel
        super.init()

        self.title = "Relationships"

        sidebarItem.regularTitle = self.title
        sidebarItem.compactTitle = self.title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.info)!
        sidebarItem.color = viewModel.tintColour()

        viewModel.report.evaluator.addObserver(self)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.report.viewed = true
    }

    override func construct(builder: FormBuilder) {

    }

    func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tintColour()
    }
}
