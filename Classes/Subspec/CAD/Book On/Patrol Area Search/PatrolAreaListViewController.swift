//
//  PatrolAreaListViewController.swift
//  MPOLKit
//
//  Created by Megan Efron on 28/12/17.
//

import UIKit

open class PatrolAreaListViewController: GenericSearchViewController {
    
    open var patrolAreaListViewModel: PatrolAreaListViewModel? {
        return viewModel as? PatrolAreaListViewModel
    }
    
    // MARK: - Setup

    required public init(viewModel: GenericSearchViewModel) {
        super.init(viewModel: viewModel)
        delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: patrolAreaListViewModel?.cancelButtonText(), style: .done, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: patrolAreaListViewModel?.doneButtonText(), style: .done, target: self, action: #selector(doneTapped))
    }
    
    // MARK: - Actions
    
    @objc public func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc public func doneTapped() {
        patrolAreaListViewModel?.doneTapped()
        navigationController?.popViewController(animated: true)
    }

}

extension PatrolAreaListViewController: GenericSearchDelegate {
    public func genericSearchViewController(_ viewController: GenericSearchViewController, didSelectRowAt indexPath: IndexPath, withSearchable searchable: GenericSearchable) {
        if let patrolArea = searchable as? PatrolAreaListItemViewModel {
            patrolAreaListViewModel?.selectedPatrolArea = patrolArea.patrolArea
            reloadForm()
        }
    }
}
