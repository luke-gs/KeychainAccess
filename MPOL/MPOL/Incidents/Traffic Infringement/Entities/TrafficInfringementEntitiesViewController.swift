//
//  TrafficInfringementEntitiesViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}
open class TrafficInfringementEntitiesViewController: FormBuilderViewController, EvaluationObserverable {

    var viewModel: TrafficInfringementEntitiesViewModel

    public init(viewModel: TrafficInfringementEntitiesViewModel) {
        self.viewModel = viewModel
        super.init()
        viewModel.addObserver(self)

        title = "Entities"

        sidebarItem.regularTitle = title
        sidebarItem.compactTitle = title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.list)!
        sidebarItem.color = viewModel.tabColor

        loadingManager.noContentView.titleLabel.text = "No Entities Added"
        loadingManager.noContentView.subtitleLabel.text = "This report requires at least one person or vehicle"
        loadingManager.noContentView.imageView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.dialogAlert)
        loadingManager.noContentView.actionButton.setTitle("Add Entity", for: .normal)
        loadingManager.noContentView.actionButton.addTarget(self, action: #selector(newEntityHandler), for: .touchUpInside)

        loadingManager.state = viewModel.currentLoadingManagerState
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override open func construct(builder: FormBuilder) {
        builder.title = title
        builder.forceLinearLayout = true

        builder += HeaderFormItem(text: viewModel.headerText).actionButton(title: "Add", handler: newEntityHandler(_:))

        let entities = viewModel.entities


        builder += entities.map { entity in
            return  viewModel.displayable(for: entity).summaryListFormItem()
                .accessory(nil)

                .editActions([CollectionViewFormEditAction(title: "Delete", color: .orangeRed, handler: { cell, indexPath in
                    self.viewModel.removeEntity(entity)
                    self.updateLoadingManager()
                    self.reloadForm()
                })])
        }
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = evaluator.isComplete == true ? .midGreen : .red
    }

    // MARK: - PRIVATE

    @objc private func newEntityHandler(_ sender: UIButton) {

        let entityPickerViewModel = EntityPickerViewModel(dismissClosure: { entity in

            self.viewModel.addEntity(entity)
            self.updateLoadingManager()
            self.reloadForm()

            self.dismissAnimated()
        } )
        
        let viewController = EntityPickerViewController(viewModel: entityPickerViewModel)

        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                                          style: .plain,
                                                                          target: self,
                                                                          action: #selector(cancelTapped))


        let navController = PopoverNavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .formSheet

        present(navController, animated: true, completion: nil)
    }

    @objc private func cancelTapped() {
        dismissAnimated()
    }

    func updateLoadingManager() {
        loadingManager.state = viewModel.currentLoadingManagerState
    }

}

