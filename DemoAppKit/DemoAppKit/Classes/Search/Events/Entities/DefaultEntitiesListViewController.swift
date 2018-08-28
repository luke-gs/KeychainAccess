//
//  DefaultEntitiesListViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class DefaultEntitiesListViewController: FormBuilderViewController, EvaluationObserverable, EntityPickerDelegate {

    var viewModel: EntitiesListViewModel

    public init(viewModel: EntitiesListViewModel) {
        self.viewModel = viewModel
        super.init()
        viewModel.addObserver(self)

        title = "Entities"

        sidebarItem.regularTitle = title
        sidebarItem.compactTitle = title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.list)!
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor

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

    override open func construct(builder: FormBuilder) {
        builder.title = title
        builder.forceLinearLayout = true

        builder += LargeTextHeaderFormItem(text: viewModel.headerText)
            .separatorColor(.clear)
            .actionButton(title: "Add", handler: newEntityHandler(_:))

        for entity in viewModel.entities {

            let image = AssetManager.shared.image(forKey: .penStub)
            let accessory = CustomItemAccessory(onCreate: { UIImageView(image: AssetManager.shared.image(forKey: .edit)) }, size: image?.size ?? .zero)
            builder += viewModel.displayable(for: entity).summaryListFormItem()
                        .separatorColor(.clear)
                        .subtitle(viewModel.retrieveInvolvements(for: entity)?.joined(separator: ", "))
                        .accessory(nil)
                        .badgeColor(nil)
                        .badge(0)
                        .accessory(accessory)
                        .selectionStyle(.none)
                        .editActions([CollectionViewFormEditAction(title: "Delete", color: .orangeRed, handler: { cell, indexPath in
                            self.viewModel.removeEntity(entity)
                            self.updateLoadingManager()
                            self.reloadForm()
                        })])
                        .onSelection({ cell in
                            self.presentEditViewController( entity: entity, cell: cell)
                        })

            for action in viewModel.retrieveAdditionalActions(for: entity) ?? [] {
                builder += SubItemFormItem()
                    .separatorColor(.clear)
                    .title(action.additionalActionType.rawValue)
                    .detail(action.evaluator.isComplete ? "Complete" : "Incomplete")
                    .detailFont(UIFont.systemFont(ofSize: 13, weight: .semibold))
                    .detailColorKey(action.evaluator.isComplete ? .secondaryText : .redText)
                    .image(AssetManager.shared.image(forKey: .documentFilled))
                    .imageTintColorKey(.primaryText)
                    .selectionStyle(.none)
                    .actionButton(title: "Open", handler: { (sender) in
                        self.presentAdditionalAction(reports: action.reports)
                    })
                    .editActions([CollectionViewFormEditAction(title: "Delete", color: .orangeRed, handler: { cell, indexPath in
                        self.viewModel.removeAdditionalAction(entity: entity, action: action)
                        self.updateLoadingManager()
                        self.reloadForm()
                    })])
                    .onSelection({ cell in
                        self.presentAdditionalAction(reports: action.reports)
                    })
            }
        }

    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }

    // MARK: - PRIVATE

    @objc private func newEntityHandler(_ sender: UIButton) {

        var entityPickerViewModel = viewModel.entityPickerViewModel
        entityPickerViewModel.delegate = self
        
        let viewController = EntityPickerViewController(viewModel: entityPickerViewModel)
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                                          style: .plain,
                                                                          target: self,
                                                                          action: #selector(cancelTapped))

        let navController = PopoverNavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .formSheet

        present(navController, animated: true, completion: nil)
    }

    private func presentAdditionalAction(reports: [IncidentReportable]) {
        guard let viewController = self.viewModel.screenBuilding.viewControllers(for: reports).first else {
            return
        }
        let navController = ThemedNavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .pageSheet
        navController.dismissHandler = { animated in
            self.reloadForm()
            self.viewModel.report.evaluator.updateEvaluation(for: .additionalActionsComplete)
        }
        self.present(navController, animated: true, completion: nil)
    }

    @objc private func cancelTapped() {
        dismissAnimated()
    }

    func updateLoadingManager() {
        loadingManager.state = viewModel.currentLoadingManagerState
    }

    public func finishedPicking(_ entity: MPOLKitEntity) {

        if !viewModel.involvements(for: entity).isEmpty {
            presentPickerViewController(type: .involvement, entity: entity)

        } else if !viewModel.additionalActions(for: entity).isEmpty {
            presentPickerViewController(type: .additionalAction, entity: entity)

        } else {
            viewModel.addEntity(entity, with: [], and: [])
            updateLoadingManager()
            reloadForm()
            dismissAnimated()
        }
    }

    public func presentPickerViewController(type: EntityPickerType, entity: MPOLKitEntity) {

        let definition = viewModel.definition(for: type, from: self, with: entity)
        let dataSource = definition.dataSource
        let viewController = CustomPickerController(dataSource: dataSource)

        viewController.finishUpdateHandler = definition.completion


        if let navController = presentedViewController as? UINavigationController {
            navController.pushViewController(viewController, animated: false)
        } else {

            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))

            let navController = PopoverNavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .formSheet

            present(navController, animated: true, completion: nil)
        }
    }

    private func presentEditViewController( entity: MPOLKitEntity, cell: CollectionViewFormCell) {

        let editItems = viewModel.editItems(for: entity)
        let pickerTableViewController = PickerTableViewController(style: .plain, items: editItems)
        pickerTableViewController.title = "Edit Actions"
        pickerTableViewController.allowsQuickSelection = false
        pickerTableViewController.allowsMultipleSelection = false
        pickerTableViewController.accessoryType = .none
        pickerTableViewController.selectionUpdateHandler = { [weak self] picker, selectedIndexes in

            self?.dismiss(animated: true, completion: {
                guard let index = selectedIndexes.first else { return }
                let item = editItems[index]
                if item.subtitle == "involvement" {
                    self?.presentPickerViewController(type: .involvement, entity: entity)
                }
                if item.subtitle == "action" {
                    self?.presentPickerViewController(type: .additionalAction, entity: entity)
                }
            })
        }

        let navigationController = PopoverNavigationController(rootViewController: pickerTableViewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.sourceRect = cell.accessoryView!.bounds
        navigationController.popoverPresentationController?.permittedArrowDirections = .up
        navigationController.popoverPresentationController?.sourceView = cell.accessoryView
        self.present(navigationController, animated: true, completion: nil)
    }
}
