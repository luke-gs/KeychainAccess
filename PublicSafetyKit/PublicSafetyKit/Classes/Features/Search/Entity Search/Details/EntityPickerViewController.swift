//
//  EntityPickerViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class EntityPickerViewController: FormBuilderViewController {

    let viewModel: EntityPickerViewModel

    required public init(viewModel: EntityPickerViewModel) {
        self.viewModel = viewModel
        super.init()
        title = "Entities"
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        loadingManager.noContentView.titleLabel.text = "There are no recently viewed Entities"
        loadingManager.state = viewModel.currentLoadingManagerState

        let action = DialogAction(title: "Search for Entity") { _ in
            self.dismiss(animated: false) {
                self.presentEntitySearch()
            }
        }
        let buttonsView = DialogActionButtonsView(actions: [action])

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

    private func presentEntitySearch() {
        do {
            try SearchActivityLauncher.default.launch(.searchEntity(term: Searchable()), using: AppURLNavigator.default)
        } catch {
            let alertController = UIAlertController(title: "An Error Has Occurred", message: "Failed To Launch Entity Search", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                self.dismissAnimated()
            })
            alertController.addAction(action)
            AlertQueue.shared.add(alertController)
        }
    }

    open override func construct(builder: FormBuilder) {
        builder.title = title
        builder.enforceLinearLayout = .always

        let entities = viewModel.entities

        builder += HeaderFormItem(text: viewModel.headerTitle)

        builder += entities.map { entity in
            let displayable = viewModel.displayable(for: entity)
            return displayable.summaryListFormItem()
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
