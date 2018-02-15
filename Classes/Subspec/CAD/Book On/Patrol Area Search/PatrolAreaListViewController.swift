//
//  PatrolAreaListViewController.swift
//  MPOLKit
//
//  Created by Megan Efron on 28/12/17.
//

import UIKit

open class PatrolAreaListViewController<T: GenericSearchDelegate, U: PatrolAreaListViewModel>: GenericSearchViewController<T, U> where T.Object == U.Object {

    public typealias Object = U.Object

    // MARK: - Setup

    public required init(viewModel: U) {
        super.init(viewModel: viewModel)

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .done, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(doneTapped))
    }

    open override func construct(builder: FormBuilder) {
        builder.forceLinearLayout = true
        builder.title = viewModel.title

        for section in 0..<viewModel.numberOfSections() {
            if viewModel.hasSections == true && viewModel.isSectionHidden(section) == false {
                builder += HeaderFormItem(text: viewModel.title(for: section))
            }
            for row in 0..<viewModel.numberOfRows(in: section) {
                let indexPath = IndexPath(row: row, section: section)
                builder += SubtitleFormItem(title: viewModel.title(for: indexPath),
                                            subtitle: viewModel.description(for: indexPath),
                                            image: viewModel.image(for: indexPath),
                                            style: .default)
                    .accessory(viewModel.accessory(for: viewModel.searchable(for: viewModel.object(for: indexPath))))
                    .onSelection { [unowned self] cell in
                        if let patrolList = self.viewModel.object(for: indexPath) as? PatrolAreaListItemViewModel {
                            self.viewModel.selectedPatrolArea = patrolList.patrolArea
                            self.reloadForm()
                        }
                }
            }
        }
        // Update loading state based on whether there is any content
        loadingManager.state = builder.formItems.isEmpty ? .noContent : .loaded
    }

    // MARK: - Actions

    @objc public func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc public func doneTapped() {
        viewModel.doneTapped()
        navigationController?.popViewController(animated: true)
    }
}

extension PatrolAreaListViewController: GenericSearchDelegate {
    public func genericSearchViewController(_ viewController: UIViewController, didSelectRowAt indexPath: IndexPath, withObject object: GenericSearchable) {
        if let patrolArea = object as? PatrolAreaListItemViewModel {
            viewModel.selectedPatrolArea = patrolArea.patrolArea
            reloadForm()
        }
    }
}
