//
//  DefaultPropertyViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public class DefaultPropertyViewController: FormBuilderViewController, EvaluationObserverable {

    let viewModel: DefaultPropertyViewModel
    let delegate = DefaultPropertyViewControllerSelectionHandler()

    public required convenience init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public init(viewModel: DefaultPropertyViewModel) {
        self.viewModel = viewModel
        super.init()
        self.viewModel.report.evaluator.addObserver(self)

        title = viewModel.title

        sidebarItem.regularTitle = title
        sidebarItem.compactTitle = title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.alert)!
        sidebarItem.color = self.viewModel.tabColor
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        loadingManager.state = viewModel.loadingManagerState
        loadingManager.noContentView.titleLabel.text = "No \(viewModel.title) Added"
        loadingManager.noContentView.subtitleLabel.text = "This report requires at least one \(viewModel.title)"
        loadingManager.noContentView.imageView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.dialogAlert)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.report.viewed = true
        reloadForm()
        loadingManager.state = viewModel.loadingManagerState
    }


    override public func construct(builder: FormBuilder) {
        builder.title = title
        builder.forceLinearLayout = true
        builder += HeaderFormItem(text: "General")
        builder += PickerFormItem(pickerAction: PropertyAction(viewModel: viewModel, delegate: delegate))
            .title("Type")
            .selectedValue(self.viewModel.report.type)
            .accessory(ItemAccessory.dropDown)
        builder += HeaderFormItem(text: "Media").actionButton(title: "Manage", handler: {_ in})
        builder += HeaderFormItem(text: "Property Details")

    }

    // MARK: Eval
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tabColor
        loadingManager.state = viewModel.loadingManagerState
    }
}

// Separate class for SearchDisplayableDelegate implementation, due to cyclic reference in generic type inference
open class DefaultPropertyViewControllerSelectionHandler: SearchDisplayableDelegate {
    public typealias Object = CustomSearchDisplayable

    public func genericSearchViewController(_ viewController: UIViewController, didSelectRowAt indexPath: IndexPath, withObject object: CustomSearchDisplayable) {
        print(object)
    }
}
