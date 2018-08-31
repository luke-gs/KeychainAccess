//
//  RetrievedEventSummaryViewController.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class RetrievedEventSummaryViewController: FormBuilderViewController {

    private var viewModel: RetrievedEventSummaryViewModel

    init(viewModel: RetrievedEventSummaryViewModel) {
        self.viewModel = viewModel
        super.init()

        title = "Event"
        loadingManager.state = .loaded
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    override open func construct(builder: FormBuilder) {
        builder.title = title
        builder.forceLinearLayout = true

        builder += LargeTextHeaderFormItem(text: viewModel.eventName)
            .separatorColor(.clear)
            .textAlignment(.center)
            .layoutMargins(UIEdgeInsets(top: 4, left: 48, bottom: 16, right: 48))

        builder += RowDetailFormItem(title: viewModel.recordedDateLabel, detail: viewModel.recordedDateLabel)
            .separatorColor(.clear)

        builder += RowDetailFormItem(title: viewModel.eventNumberLabel, detail: viewModel.eventNumberValue)

        builder += LabelFormItem(text: viewModel.eventDescription)

    }

}
