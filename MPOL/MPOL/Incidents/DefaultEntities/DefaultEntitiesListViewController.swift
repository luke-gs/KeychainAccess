//
//  DefaultEntitiesListViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit

open class DefaultEntitiesListViewController: FormBuilderViewController, EvaluationObserverable, EntityPickerDelegate {

    private(set) var viewModel: DefaultEntitiesListViewModel

    public init(viewModel: DefaultEntitiesListViewModel) {
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

        builder += HeaderFormItem(text: viewModel.headerText).actionButton(title: "Add", handler: newEntityHandler(_:))

        builder += viewModel.entities.map { entity in
            return viewModel.displayable(for: entity).summaryListFormItem()
                .subtitle(viewModel.retrieveInvolvements(for: entity)?.joined(separator: ", "))
                .accessory(nil)
                .badgeColor(nil)
                .badge(0)
                .editActions([CollectionViewFormEditAction(title: "Delete", color: .orangeRed, handler: { cell, indexPath in
                    self.viewModel.removeEntity(entity)
                    self.updateLoadingManager()
                    self.reloadForm()
                })])
                .onSelection({ cell in
                    guard let indexPath = self.collectionView?.indexPath(for: cell) else { return }
                    self.collectionView?.deselectItem(at: indexPath, animated: true)
                    self.presentInvolvementPickerVC(entity: entity)
                })
        }
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }

    // MARK: - PRIVATE

    @objc private func newEntityHandler(_ sender: UIButton) {

        let entityPickerViewModel = EntityPickerViewModel()
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

    @objc private func cancelTapped() {
        dismissAnimated()
    }

    func updateLoadingManager() {
        loadingManager.state = viewModel.currentLoadingManagerState
    }

    // MARK:- EntityPickerDelegateMethods

    func finishedPicking(_ entity: MPOLKitEntity) {

        presentInvolvementPickerVC(entity: entity)
    }

    func presentInvolvementPickerVC(entity: MPOLKitEntity) {

        let editingEntity = viewModel.entities.contains(entity)
        let displayable = viewModel.displayable(for: entity)
        let headerConfig = SearchHeaderConfiguration(title: displayable.title,
                                                     subtitle: "No involvements selected",
                                                     image: displayable.thumbnail(ofSize: .small),
                                                     imageStyle: .entity,
                                                     tintColor: displayable.iconColor,
                                                     borderColor: displayable.borderColor)

        let selectedObjects = viewModel.retrieveInvolvements(for: entity) ?? []
        let datasource = InvolvementSearchDatasource(objects: Involvement.casesFor(entity),
                                                     selectedObjects: selectedObjects,
                                                            configuration: headerConfig)
        datasource.header = CustomisableSearchHeaderView(displayView: DefaultSearchHeaderDetailView(configuration: headerConfig))
        let viewController = CustomPickerController(datasource: datasource)

        if editingEntity {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        }

        viewController.finishUpdateHandler = { controller, indexes in
            let involvements = controller.objects.enumerated()
                .filter({ indexes.contains($0.offset) })
                .compactMap({ $0.element as? Involvement })
            
                if editingEntity {
                    self.viewModel.update(involvements.map { $0.rawValue }, for: entity)
                } else {
                    self.viewModel.addEntity(entity, with: involvements.map { $0.rawValue })
                }

            self.updateLoadingManager()
            self.reloadForm()
            self.dismissAnimated()
        }

        if let navController = presentedViewController as? UINavigationController {
            navController.pushViewController(viewController, animated: false)
        } else {
            let navController = PopoverNavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .formSheet

            present(navController, animated: true, completion: nil)
        }

    }
}

public enum Involvement: String, Pickable {

    public var title: String? {
        return self.rawValue
    }
    public var subtitle: String? {
        return nil
    }

    case offence = "Involved in Offence"
    case crash = "Involved in Crash"
    case damaged = "Damaged"
    case towed = "Towed"
    case abandoned = "Abandoned"
    case defective = "Defective"
    case driver = "Driver"
    case used = "Used"

    static func casesFor(_ entity: MPOLKitEntity) -> [Involvement] {

        switch entity {
        case is Person:
            return [.offence, .crash, .driver]
        case is Vehicle:
            return [.damaged, .towed, .abandoned, .defective, .used]
        default:
            return []
        }
    }
}




