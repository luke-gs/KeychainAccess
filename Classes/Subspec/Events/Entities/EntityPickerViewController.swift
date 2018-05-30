//
//  EntityPickerViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class EntityPickerViewController: FormBuilderViewController {

    let viewModel: EntityPickerViewModel
    private(set) var buttonsView: DialogActionButtonsView

    required public init(viewModel: EntityPickerViewModel) {
        self.viewModel = viewModel

        let action = DialogAction(title: "Search for Entity") { _ in
            // TODO: code to search for another entity
        }
        buttonsView = DialogActionButtonsView(actions: [action])

        super.init()
        title = "Entities"
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        loadingManager.noContentView.titleLabel.text = "There are no recently used Entities"
        loadingManager.state = viewModel.currentLoadingManagerState

        guard let collectionView = collectionView else { return }
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(buttonsView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: buttonsView.topAnchor),

            buttonsView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateEmptyState()
        reloadForm()
    }

    open override func construct(builder: FormBuilder) {
        builder.title = title
        builder.forceLinearLayout = true

        let entities = viewModel.entities

        builder += HeaderFormItem(text: "Recently Viewed")

        builder += entities.map { entity in
            return viewModel.displayable(for: entity)
                .summaryListFormItem()
                .badgeColor(nil)
                .badge(0)
                .accessory(nil)
                .onSelection ({ cell in
                    guard let indexPath = self.collectionView?.indexPath(for: cell) else { return }
                    self.collectionView?.deselectItem(at: indexPath, animated: true)
                    self.viewModel.delegate?.finishedPicking(entity)
                })
        }
    }

    private func updateEmptyState() {
        self.loadingManager.state = viewModel.currentLoadingManagerState
    }

}
