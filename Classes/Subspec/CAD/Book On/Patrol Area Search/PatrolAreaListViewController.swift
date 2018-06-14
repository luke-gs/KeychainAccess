//
//  PatrolAreaListViewController.swift
//  MPOLKit
//
//  Created by Megan Efron on 28/12/17.
//

import UIKit

open class PatrolAreaListViewController: SearchDisplayableViewController<PatrolAreaListViewControllerSelectionHandler, PatrolAreaListViewModel> {

    // MARK: - Setup

    public required init(viewModel: PatrolAreaListViewModel) {
        super.init(viewModel: viewModel)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: viewModel.cancelButtonText(), style: .done, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: viewModel.doneButtonText(), style: .done, target: self, action: #selector(doneTapped))
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Set delegate to internal selection handler
        delegate = PatrolAreaListViewControllerSelectionHandler(self)
        
        if let selectedIndex = viewModel.indexOfSelectedItem() {
            DispatchQueue.main.async {
                self.collectionView?.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: .centeredVertically, animated: false)
            }
        }
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
                        self.delegate?.genericSearchViewController(self, didSelectRowAt: indexPath, withObject: self.viewModel.object(for: indexPath))
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

// Separate class for SearchDisplayableDelegate implementation, due to cyclic reference in generic type inference
open class PatrolAreaListViewControllerSelectionHandler: SearchDisplayableDelegate {
    public typealias Object = CustomSearchDisplayable
    private var listViewController: PatrolAreaListViewController

    init(_ listViewController: PatrolAreaListViewController) {
        self.listViewController = listViewController
    }

    public func genericSearchViewController(_ viewController: UIViewController, didSelectRowAt indexPath: IndexPath, withObject object: CustomSearchDisplayable) {
        if let patrolArea = object as? PatrolAreaListItemViewModel {
            listViewController.viewModel.selectedPatrolArea = patrolArea.patrolArea
            listViewController.reloadForm()
        }
    }
}
