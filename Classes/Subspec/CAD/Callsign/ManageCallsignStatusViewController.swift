//
//  ManageCallsignStatusViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

/// View controller for managing the current callsign status
open class ManageCallsignStatusViewController: UIViewController, PopoverViewController {

    open let viewModel: ManageCallsignStatusViewModel

    /// Scroll view for content view
    open var scrollView: UIScrollView!

    /// Content view for all content above buttons
    open var contentView: UIView!

    /// Flow layout
    open var collectionViewLayout: UICollectionViewFlowLayout!

    /// Collection view for status items
    open var collectionView: UICollectionView!

    /// Stack view for action buttons
    open var buttonStackView: UIStackView!

    /// The button separator views
    open var buttonSeparatorViews: [UIView]!

    /// Form for displaying the current incident (or nothing)
    open var incidentFormVC: CallsignIncidentFormViewController!

    /// Height constraint for current incident form
    open var incidentFormHeight: NSLayoutConstraint!

    /// Support being transparent when in popover/form sheet
    open var wantsTransparentBackground: Bool = true {
        didSet {
            view.backgroundColor = wantsTransparentBackground ? UIColor.clear : theme.color(forKey: .background)!
            incidentFormVC.wantsTransparentBackground = wantsTransparentBackground
        }
    }

    /// Return the current theme
    private var theme: Theme {
        return ThemeManager.shared.theme(for: .current)
    }
    
    /// The index path that is currently loading
    private var loadingIndexPath: IndexPath?

    // MARK: - Initializers

    public init(viewModel: ManageCallsignStatusViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        createSubviews()
        createConstraints()

        // Observe theme changes for custom collection view
        NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }


    // MARK: - View lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        setTitleView(title: viewModel.navTitle(), subtitle: viewModel.navSubtitle())

        // Set initial background color (this may change in wantsTransparentBackground)
        view.backgroundColor = theme.color(forKey: .background)!
        setupNavigationBarButtons()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitleView(title: viewModel.navTitle(), subtitle: viewModel.navSubtitle())
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Update the item size and title view based on current traits
        updateItemSizeForTraits()
        setTitleView(title: viewModel.navTitle(), subtitle: viewModel.navSubtitle())
        setupNavigationBarButtons()

        incidentFormHeight.constant = viewModel.shouldShowIncident ? incidentFormVC.calculatedContentHeight() : 0
    }

    /// Update the item size based on size class
    open func updateItemSizeForTraits() {
        let availableWidth = collectionView.bounds.width - collectionViewLayout.sectionInset.left - collectionViewLayout.sectionInset.right
        if self.traitCollection.horizontalSizeClass == .compact {
            self.collectionViewLayout.itemSize = CGSize(width: availableWidth / 2, height: 45)
        } else {
            self.collectionViewLayout.itemSize = CGSize(width: availableWidth / 4, height: 75)
        }
        self.collectionViewLayout.invalidateLayout()
    }
    
    /// Adds or removes bar button items for the curernt presented state
    open func setupNavigationBarButtons() {
        // Create done button
        if presentingViewController != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDoneButton(_:)))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }

    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            // Update the item size and title view based on new traits
            self.updateItemSizeForTraits()
            self.setTitleView(title: self.viewModel.navTitle(), subtitle: self.viewModel.navSubtitle())
            self.setupNavigationBarButtons()
        }, completion: nil)
    }

    open func createSubviews() {
        scrollView = UIScrollView(frame: .zero)
        view.addSubview(scrollView)

        contentView = UIView(frame: .zero)
        scrollView.addSubview(contentView)

        incidentFormVC = CallsignIncidentFormViewController(viewModel: viewModel.incidentViewModel)
        incidentFormVC.view.backgroundColor = UIColor.clear
        self.addChildViewController(incidentFormVC, toView: contentView)

        collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 16, left: 24, bottom: 0, right: 24)
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.minimumLineSpacing = 10

        collectionView = IntrinsicHeightCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(ManageCallsignStatusViewCell.self)
        contentView.addSubview(collectionView)

        buttonStackView = UIStackView(frame: .zero)
        buttonStackView.axis = .vertical
        buttonStackView.distribution = .equalSpacing
        buttonStackView.spacing = 0
        view.addSubview(buttonStackView)

        let tintColor = theme.color(forKey: .tint)!

        buttonSeparatorViews = []
        for (index, buttonText) in viewModel.actionButtons.enumerated() {
            let separatorView = UIView(frame: .zero)
            separatorView.backgroundColor = theme.color(forKey: .separator)
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
            buttonSeparatorViews.append(separatorView)
            buttonStackView.addArrangedSubview(separatorView)

            let button = UIButton(type: .custom)
            let inset = 20 as CGFloat
            button.contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
            button.setTitle(buttonText, for: .normal)
            button.setTitleColor(tintColor, for: .normal)
            button.setTitleColor(tintColor.withAlphaComponent(0.5), for: .highlighted)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            button.addTarget(self, action: #selector(didTapActionButton(_:)), for: .touchUpInside)
            button.tag = index
            buttonStackView.addArrangedSubview(button)
        }
    }

    open func createConstraints() {
        let incidentFormView = incidentFormVC.view!
        incidentFormView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false

        buttonStackView.setContentCompressionResistancePriority(.required, for: .vertical)
        incidentFormView.setContentCompressionResistancePriority(.required, for: .vertical)

        incidentFormHeight = incidentFormView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            incidentFormView.topAnchor.constraint(equalTo: contentView.topAnchor),
            incidentFormView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            incidentFormView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            incidentFormHeight,

            collectionView.topAnchor.constraint(equalTo: incidentFormView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    open func decorate(cell: ManageCallsignStatusViewCell, with viewModel: ManageCallsignStatusItemViewModel, selected: Bool) {
        cell.titleLabel.text = viewModel.title
        cell.titleLabel.font = .systemFont(ofSize: 13.0, weight: selected ? UIFont.Weight.semibold : UIFont.Weight.regular)
        cell.titleLabel.textColor = theme.color(forKey: .secondaryText)!

        cell.imageView.image = viewModel.image
        cell.imageView.tintColor = theme.color(forKey: selected ? .tint : .secondaryText)!
        
        cell.spinner.color = theme.color(forKey: .tint)
    }

    @objc private func didTapDoneButton(_ button: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func didTapActionButton(_ button: UIButton) {
        viewModel.didTapActionButtonAtIndex(button.tag)
    }
    
    // MARK: - Theme

    @objc private func interfaceStyleDidChange() {
        apply(ThemeManager.shared.theme(for: .current))
    }

    open func apply(_ theme: Theme) {
        // Theme button separators
        for separatorView in buttonSeparatorViews {
            separatorView.backgroundColor = theme.color(forKey: .separator)
        }

        // Theme headers
        let sectionHeaderIndexPaths = collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionElementKindSectionHeader)
        for indexPath in sectionHeaderIndexPaths {
            if let headerView = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: indexPath) {
                self.collectionView(collectionView, willDisplaySupplementaryView: headerView, forElementKind: UICollectionElementKindSectionHeader, at: indexPath)
            }
        }
    }


    // MARK: - Internal
    
    private func set(loading: Bool, at indexPath: IndexPath) {
        self.loadingIndexPath = loading ? indexPath : nil
        UIView.performWithoutAnimation {
            collectionView.performBatchUpdates({
                collectionView.reloadItems(at: [indexPath])
            }, completion: nil)
        }
    }

}

// MARK: - UICollectionViewDataSource
extension ManageCallsignStatusViewController: UICollectionViewDataSource {

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(for: section)
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: ManageCallsignStatusViewCell.self, for: indexPath)
        if let item = viewModel.item(at: indexPath) {
            decorate(cell: cell, with: item, selected: viewModel.selectedIndexPath == indexPath)
        }
        return cell
    }

    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            header.text = viewModel.headerText(at: indexPath.section)
            header.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
            return header
        }
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "", for: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ManageCallsignStatusViewCell else { return }
        cell.isLoading = indexPath == loadingIndexPath
    }

    open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if let headerView = view as? CollectionViewFormHeaderView {
            headerView.tintColor = theme.color(forKey: .secondaryText)
            headerView.separatorColor = theme.color(forKey: .separator)
        }
    }
}

// MARK: - CADFormCollectionViewModelDelegate
extension ManageCallsignStatusViewController: CADFormCollectionViewModelDelegate {

    open func sectionsUpdated() {
        collectionView.reloadData()
    }

    open func dismiss() {
        dismiss(animated: true, completion: nil)
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension ManageCallsignStatusViewController: UICollectionViewDelegateFlowLayout {

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: CollectionViewFormHeaderView.minimumHeight)
    }
}

// MARK: - UICollectionViewDelegate
extension ManageCallsignStatusViewController: UICollectionViewDelegate {

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

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)

        if indexPath != viewModel.selectedIndexPath, loadingIndexPath == nil {
            
            let oldIndexPath = viewModel.selectedIndexPath
            set(loading: true, at: indexPath)

            firstly {
                // Attempt to change state
                return viewModel.setSelectedIndexPath(indexPath)
            }.then { _ in
                UIView.performWithoutAnimation {
                    collectionView.performBatchUpdates({
                        collectionView.reloadItems(at: [indexPath, oldIndexPath])
                    }, completion: nil)
                }
            }.always {
                self.set(loading: false, at: indexPath)
            }.catch { error in
                AlertQueue.shared.addErrorAlert(message: error.localizedDescription)
            }
        }
    }

}
