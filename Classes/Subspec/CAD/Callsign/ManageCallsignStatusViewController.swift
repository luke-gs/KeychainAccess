//
//  ManageCallsignStatusViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// View controller for managing the current callsign status
class ManageCallsignStatusViewController: UIViewController, PopoverViewController {

    public let viewModel: ManageCallsignStatusViewModel

    /// Flow layout
    public var collectionViewLayout: UICollectionViewFlowLayout!

    /// Collection view for status items
    public var collectionView: UICollectionView!

    /// Stack view for action buttons
    public var buttonStackView: UIStackView!

    /// Support being transparent when in popover/form sheet
    open var wantsTransparentBackground: Bool = true {
        didSet {
            let theme = ThemeManager.shared.theme(for: .current)
            view.backgroundColor = wantsTransparentBackground ? UIColor.clear : theme.color(forKey: .background)!
        }
    }

    // MARK: - Initializers

    public init(viewModel: ManageCallsignStatusViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        createSubviews()
        createConstraints()
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    // MARK: - View lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.navTitle()

        // Set initial background color (this may change in wantsTransparentBackground)
        let theme = ThemeManager.shared.theme(for: .current)
        view.backgroundColor = theme.color(forKey: .background)!

        // Create done button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDoneButton(_:)))
    }

    public func createSubviews() {
        collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.itemSize = CGSize(width: 116, height: 90)
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.minimumLineSpacing = 0

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(ManageCallsignStatusViewCell.self)
        view.addSubview(collectionView)

        buttonStackView = UIStackView(frame: .zero)
        buttonStackView.axis = .vertical
        buttonStackView.distribution = .equalSpacing
        buttonStackView.spacing = 0
        view.addSubview(buttonStackView)

        let theme = ThemeManager.shared.theme(for: .current)
        let tintColor = theme.color(forKey: .tint)!

        for (index, buttonText) in viewModel.actionButtons.enumerated() {
            let separatorView = UIView(frame: .zero)
            separatorView.backgroundColor = iOSStandardSeparatorColor
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
            buttonStackView.addArrangedSubview(separatorView)

            let button = UIButton(type: .custom)
            let inset = 16 as CGFloat
            button.contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
            button.setTitle(buttonText, for: .normal)
            button.setTitleColor(tintColor, for: .normal)
            button.setTitleColor(tintColor.withAlphaComponent(0.5), for: .highlighted)
            button.addTarget(self, action: #selector(didTapActionButton(_:)), for: .touchUpInside)
            button.tag = index
            buttonStackView.addArrangedSubview(button)
        }
    }

    public func createConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor),

            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).withPriority(.almostRequired),
        ])
    }

    open func decorate(cell: ManageCallsignStatusViewCell, with viewModel: ManageCallsignStatusItemViewModel, selected: Bool) {
        let theme = ThemeManager.shared.theme(for: .current)

        cell.titleLabel.text = viewModel.title
        cell.titleLabel.font = .systemFont(ofSize: 13.0, weight: selected ? UIFont.Weight.semibold : UIFont.Weight.regular)
        cell.titleLabel.textColor = theme.color(forKey: .secondaryText)!

        cell.imageView.image = viewModel.image
        cell.imageView.tintColor = theme.color(forKey: selected ? .tint : .primaryText)!
    }

    @objc private func didTapDoneButton(_ button: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func didTapActionButton(_ button: UIButton) {
        viewModel.didTapActionButtonAtIndex(button.tag)
    }

}

// MARK: - UICollectionViewDataSource
extension ManageCallsignStatusViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(for: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: ManageCallsignStatusViewCell.self, for: indexPath)
        if let item = viewModel.item(at: indexPath) {
            decorate(cell: cell, with: item, selected: viewModel.selectedIndexPath == indexPath)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            let theme = ThemeManager.shared.theme(for: .current)
            header.text = viewModel.headerText(at: indexPath.section)
            header.tintColor = theme.color(forKey: .secondaryText)!
            header.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
            return header
        }
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "", for: indexPath)
    }

}

// MARK: - CADFormCollectionViewModelDelegate
extension ManageCallsignStatusViewController: CADFormCollectionViewModelDelegate {

    public func sectionsUpdated() {
        collectionView.reloadData()
    }

    public func dismiss() {
        dismiss(animated: true, completion: nil)
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension ManageCallsignStatusViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: CollectionViewFormHeaderView.minimumHeight)
    }
}

// MARK: - UICollectionViewDelegate
extension ManageCallsignStatusViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath), indexPath != viewModel.selectedIndexPath {
            cell.contentView.alpha = 0.5
        }
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.alpha = 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)

        if indexPath != viewModel.selectedIndexPath {

            let oldIndexPath = viewModel.selectedIndexPath
            _ = viewModel.setSelectedIndexPath(indexPath).then { status -> Void in
                // Cancel progress overlay
                UIView.performWithoutAnimation {
                    collectionView.performBatchUpdates({
                        collectionView.reloadItems(at: [indexPath, oldIndexPath])
                    }, completion: nil)
                }
            }
        }
    }

}
