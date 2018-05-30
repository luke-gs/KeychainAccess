//
//  DomesticViolencePropertyViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit

open class DomesticViolencePropertyViewController: FormBuilderViewController, EvaluationObserverable {

    private(set) var viewModel: DomesticViolencePropertyViewModel

    public init(viewModel: DomesticViolencePropertyViewModel) {
        self.viewModel = viewModel
        super.init()
        viewModel.addObserver(self)

        //set initial loading manager state
        self.setLoadingManagerState()

        title = "Property"

        sidebarItem.regularTitle = title
        sidebarItem.compactTitle = title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.list)!
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor

        loadingManager.noContentView.titleLabel.text = "No Property Added"
        loadingManager.noContentView.subtitleLabel.text = "Optional"
        loadingManager.noContentView.actionButton.setTitle("Add Property", for: .normal)
        loadingManager.noContentView.actionButton.addTarget(self, action: #selector(addProperty), for: .touchUpInside)
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.report.viewed = true
    }

    override open func construct(builder: FormBuilder) {
        builder.title = title
        builder.forceLinearLayout = true
    }

    private func setLoadingManagerState() {
        self.loadingManager.state = viewModel.hasProperty ? .loaded : .noContent
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }

    @objc public func addProperty() {
        let viewController = AddPropertyViewController(viewModel: DefaultPropertyViewModel(report: DefaultPropertyReport(event: viewModel.report.event!, incident: viewModel.report.incident)))
        let navigationController = PopoverNavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true, completion: nil)
    }
}
