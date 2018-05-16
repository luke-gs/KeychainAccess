//
//  CADStatusViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 20/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CADStatusViewController: FormBuilderViewController {
    
    open let viewModel: CADStatusViewModel
    
    // MARK: - Initializers
    
    public init(viewModel: CADStatusViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    // MARK: - View lifecycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        calculatesContentHeight = true
        setupConstraints()
        
        // Set title and initial background color
        title = viewModel.navTitle()

        let theme = ThemeManager.shared.theme(for: userInterfaceStyle)
        view.backgroundColor = theme.color(forKey: .background)!
    }
    
    private func setupConstraints() {
        guard let formCollectionView = collectionView else { return }

        // Change collection view to not use autoresizing mask constraints so it uses intrinsic content height
        formCollectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            formCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            formCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            formCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            formCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// We need to override viewDidLayoutSubviews as well as willTransition due to behaviour of popover controller
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update the item size
        self.updateItemSizeForTraits()
    }
    
    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            // Update the item size
            self.updateItemSizeForTraits()
        }, completion: nil)
    }
    
    /// Update the item size based on size class
    open func updateItemSizeForTraits() {
        self.formLayout.invalidateLayout()
    }

    open override func construct(builder: FormBuilder) {
        builder.forceLinearLayoutWhenCompact = false

        for sectionIndex in 0..<viewModel.numberOfSections() {
            builder += HeaderFormItem(text: viewModel.headerText(at: sectionIndex))
//            header.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
//            headerView.tintColor = theme.color(forKey: .secondaryText)
//            headerView.separatorColor = theme.color(forKey: .separator)


            for rowIndex in 0..<viewModel.numberOfItems(for: sectionIndex) {
                if let item = viewModel.item(at: IndexPath(row: rowIndex, section: sectionIndex)) {
                    builder += CallsignStatusFormItem(text: item.title, image: item.image)
                }
            }
        }
    }

//    open func decorate(cell: CallsignStatusViewCell, with viewModel: ManageCallsignStatusItemViewModel, selected: Bool) {
//        cell.showsCompactHorizontal = self.viewModel.showsCompactHorizontal
//        cell.titleLabel.text = viewModel.title
//        cell.titleLabel.font = .systemFont(ofSize: 13.0, weight: selected ? UIFont.Weight.semibold : UIFont.Weight.regular)
//        cell.titleLabel.textColor = theme.color(forKey: .secondaryText)!
//
//        cell.imageView.image = viewModel.image
//        cell.imageView.tintColor = theme.color(forKey: selected ? .tint : .secondaryText)!
//
//        cell.spinner.color = theme.color(forKey: .tint)
//    }

}

// MARK: - UICollectionViewDelegate
extension CADStatusViewController {
    
    open func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath), indexPath != viewModel.selectedIndexPath {
            cell.contentView.alpha = 0.5
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.alpha = 1
        }
    }
}

// MARK: - CADFormCollectionViewModelDelegate
extension CADStatusViewController: CADFormCollectionViewModelDelegate {
    
    open func sectionsUpdated() {
        reloadForm()
    }
}

