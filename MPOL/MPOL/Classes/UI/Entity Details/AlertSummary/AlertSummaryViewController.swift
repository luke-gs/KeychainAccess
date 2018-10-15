//
//  AlertSummaryViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class AlertSummaryViewController: FormBuilderViewController {

    private var viewModel: AlertSummaryViewModel

    init(viewModel: AlertSummaryViewModel) {
        self.viewModel = viewModel
        super.init()

        title = "Alert"
        loadingManager.state = .loaded
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    override open func construct(builder: FormBuilder) {
        builder.title = title
        builder.enforceLinearLayout = .always

        builder += ImageDetailFormItem(image: viewModel.alertimage, title: viewModel.levelText, description: viewModel.titleText)

        builder += RowDetailFormItem(title: viewModel.dateLabel, detail: viewModel.dateIssued)
        builder += LabelFormItem(text: viewModel.description)

    }

}
