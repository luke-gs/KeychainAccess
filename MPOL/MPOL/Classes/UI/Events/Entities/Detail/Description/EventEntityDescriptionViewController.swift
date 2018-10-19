//
//  EventEntityDescriptionViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit

class EventEntityDescriptionViewController: FormBuilderViewController, EvaluationObserverable {

    let viewModel: EventEntityDescriptionViewModel

    public required init(viewModel: EventEntityDescriptionViewModel) {
        self.viewModel = viewModel
        super.init()

        self.title = "Description"

        sidebarItem.regularTitle = self.title
        sidebarItem.compactTitle = self.title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.info)!
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor

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

        let displayable = viewModel.displayable()

        builder += SummaryDetailFormItem()
            .category(displayable.category)
            .title(displayable.title)
            .detail(viewModel.description())
            .subtitle(displayable.detail1)
            .imageTintColor(displayable.iconColor)
            .borderColor(displayable.borderColor)
            .image(displayable.thumbnail(ofSize: .large))
            .onButtonTapped { }
    }

    func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }
}
