//
//  EntityPickerViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit

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

        loadingManager.noContentView.titleLabel.text = "There are no recently used Entities"
        loadingManager.state = viewModel.currentLoadingManagerState
    }

    open override func viewWillAppear(_ animated: Bool) {
        updateEmptyState()
        reloadForm()
    }

    open override func construct(builder: FormBuilder) {
        builder.title = title
        builder.forceLinearLayout = true

        let entities = viewModel.entities

        builder += HeaderFormItem(text: "Recently Used")

        builder += entities.map { entity in
            return viewModel.displayable(for: entity).summaryListFormItem()
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
