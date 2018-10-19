//
//  CallsignListViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 19/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CallsignListViewController: CADFormCollectionViewController<BookOnLandingCallsignItemViewModel>, UISearchBarDelegate {

    // MARK: - Views

    open var searchBarView: StandardSearchBarView!

    /// `super.viewModel` typecasted to our type
    open var callsignListViewModel: CallsignListViewModel? {
        return viewModel as? CallsignListViewModel
    }

    // MARK: - Setup

    public init(viewModel: CallsignListViewModel) {
        super.init(viewModel: viewModel)

        setupViews()
        setupConstraints()
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let subtitle = callsignListViewModel?.navSubtitle() {
            setTitleView(title: viewModel.navTitle(), subtitle: subtitle)
        }
    }

    open override func loadView() {
        super.loadView()

        // Disable auto resize masks and apply constraints to make space for search bar
        collectionView?.translatesAutoresizingMaskIntoConstraints = false

        if let collectionView = collectionView {
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor, constant: StandardSearchBarView.LayoutConstants.searchBarHeight),
                collectionView.leadingAnchor.constraint(equalTo: view.safeAreaOrFallbackLeadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.safeAreaOrFallbackTrailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor).withPriority(.almostRequired)
            ])
        }
    }

    /// Creates and styles views
    open func setupViews() {
        // Replace default back button with 'Back'
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(goBack))

        searchBarView = StandardSearchBarView()
        searchBarView.searchBar.delegate = self
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBarView)
    }

    /// Activates view constraints
    open func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBarView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
            searchBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    @objc open func goBack() {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Override

    override open func cellType() -> CollectionViewFormCell.Type {
        return CallsignCollectionViewCell.self
    }

    override open func decorate(cell: CollectionViewFormCell, with viewModel: BookOnLandingCallsignItemViewModel) {
        cell.highlightStyle = .fade
        cell.selectionStyle = .fade
        cell.separatorStyle = .indented
        cell.accessoryView = FormAccessoryImageView(style: .disclosure)

        if let cell = cell as? CallsignCollectionViewCell {
            cell.decorate(with: viewModel)
            cell.titleLabel.text = viewModel.title
            cell.subtitleLabel.text = viewModel.subtitle
            cell.imageView.image = viewModel.image
            cell.imageView.tintColor = viewModel.imageColor
            cell.accessoryView = FormAccessoryImageView(style: .disclosure)
        }
    }

    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)

        if let cell = cell as? CallsignCollectionViewCell {
            cell.apply(theme: ThemeManager.shared.theme(for: .current))
        }
    }

    override open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
        if let header = view as? CollectionViewFormHeaderView {
            header.separatorColor = ThemeManager.shared.theme(for: .current).color(forKey: .legacySeparator)
        }
    }

    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { (_) in
            // Update title view based on new traits
            if let subtitle = self.callsignListViewModel?.navSubtitle() {
                self.setTitleView(title: self.viewModel.navTitle(), subtitle: subtitle)
            }
        }, completion: nil)
    }

    // MARK: - UICollectionViewDelegate

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        if let screen = callsignListViewModel?.bookOnScreenForItem(indexPath) {
            present(screen)
        }
    }

    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        return 64
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        callsignListViewModel?.applyFilter(withText: searchText)
    }
}
