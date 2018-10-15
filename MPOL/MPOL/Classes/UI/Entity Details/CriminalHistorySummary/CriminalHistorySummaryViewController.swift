//
//  CriminalHistorySummaryViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//


import Foundation
import PublicSafetyKit

public class CriminalHistorySummaryViewController: FormBuilderViewController {

    private var viewModel: CriminalHistorySummaryViewModel

    init(viewModel: CriminalHistorySummaryViewModel) {
        self.viewModel = viewModel
        super.init()
        title = viewModel.navBarTitle
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(UIViewController.dismissAnimated))
        loadingManager.state = .loaded
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    override open func construct(builder: FormBuilder) {
        builder.title = title
        builder.enforceLinearLayout = .always

        builder += LargeTextHeaderFormItem(text: viewModel.primaryCharge)
            .separatorColor(.clear)
            .textAlignment(.center)

        builder += RowDetailFormItem(title: viewModel.courtNameLabel, detail: viewModel.courtNameValue)
            .separatorStyle(.none)

        builder += RowDetailFormItem(title: viewModel.occurredDateLabel, detail: viewModel.occurredDateValue)
            .separatorStyle(.none)

        builder += RowDetailFormItem(title: viewModel.courtDateLabel, detail: viewModel.courtDateValue)

        if let offenceDescription = viewModel.offenceDescription {
            builder += LabelFormItem(text: offenceDescription)
        }
    }
}
