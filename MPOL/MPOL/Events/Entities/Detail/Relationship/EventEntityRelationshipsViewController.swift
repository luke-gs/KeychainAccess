//
//  EventEntityRelationshipsViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit

class EventEntityRelationshipsViewController: FormBuilderViewController, EvaluationObserverable {

    let viewModel: EventEntityRelationshipsViewModel

    required convenience init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public required init(viewModel: EventEntityRelationshipsViewModel) {
        self.viewModel = viewModel
        super.init()

        self.title = "Relationships"

        sidebarItem.regularTitle = self.title
        sidebarItem.compactTitle = self.title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.iconRelationships)!
        sidebarItem.color = viewModel.tintColour()

        loadingManager.noContentView.titleLabel.text = "No Entities"
        loadingManager.noContentView.subtitleLabel.text = "There are no relationships that need to be defined"
        loadingManager.noContentView.imageView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.dialogAlert)

        viewModel.report.evaluator.addObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.report.viewed = true
        loadingManager.state = viewModel.loadingManagerState()
    }

    override func construct(builder: FormBuilder) {
        viewModel.dataSources.forEach { datasource in
            builder += HeaderFormItem(text: datasource.header)
            builder += datasource.entities.map { entity in
                return viewModel.displayable(for: entity).summaryListFormItem()
            }
        }
    }

    func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tintColour()
    }
}
