//
//  CallsignListViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 19/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CallsignListViewController: CADFormCollectionViewController<NotBookedOnCallsignItemViewModel>, UISearchBarDelegate {

    /// Layout sizing constants
    public struct LayoutConstants {
        static let searchBarHeight: CGFloat = 64
    }
    
    // MARK: - Views
    
    open var barBackground: UIView!
    open var searchBar: UISearchBar!

    /// `super.viewModel` typecasted to our type
    open var callsignListViewModel: CallsignListViewModel? {
        return viewModel as? CallsignListViewModel
    }
    
    /// Support being transparent when in popover/form sheet
    open override var wantsTransparentBackground: Bool {
        didSet {
            let theme = ThemeManager.shared.theme(for: .current)
            view.backgroundColor = wantsTransparentBackground ? UIColor.clear : theme.color(forKey: .background)!
        }
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
                collectionView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor, constant: LayoutConstants.searchBarHeight),
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
        
        barBackground = UIView()
        barBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(barBackground)
        
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.barTintColor = UIColor.white
        searchBar.backgroundColor = UIColor.clear
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = NSLocalizedString("Search", comment: "Search Text Placeholder")
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        barBackground.addSubview(searchBar)
    }

    open override func apply(_ theme: Theme) {
        super.apply(theme)
        barBackground.backgroundColor = theme.color(forKey: .headerBackground)
    }

    /// Activates view constraints
    open func setupConstraints() {
        NSLayoutConstraint.activate([
            barBackground.topAnchor.constraint(equalTo: view.topAnchor),
            barBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            barBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            barBackground.heightAnchor.constraint(equalToConstant: LayoutConstants.searchBarHeight),
            
            searchBar.topAnchor.constraint(equalTo: barBackground.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: barBackground.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: barBackground.trailingAnchor, constant: -8),
            searchBar.bottomAnchor.constraint(equalTo: barBackground.bottomAnchor)
        ])
    }
    
    @objc open func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Override
    
    override open func cellType() -> CollectionViewFormCell.Type {
        return CallsignCollectionViewCell.self
    }
    
    override open func decorate(cell: CollectionViewFormCell, with viewModel: NotBookedOnCallsignItemViewModel) {
        cell.highlightStyle = .fade
        cell.selectionStyle = .fade
        cell.separatorStyle = .indented
        cell.separatorColor = UIColor.red
        cell.accessoryView = FormAccessoryView(style: .disclosure)
        
        if let cell = cell as? CallsignCollectionViewCell {
            cell.decorate(with: viewModel)
            cell.titleLabel.text = viewModel.title
            cell.subtitleLabel.text = viewModel.subtitle
            cell.imageView.image = viewModel.image
            cell.imageView.tintColor = viewModel.imageColor
            cell.accessoryView = FormAccessoryView(style: .disclosure)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let cell = cell as? CallsignCollectionViewCell {
            cell.separatorColor = iOSStandardSeparatorColor
            cell.apply(theme: ThemeManager.shared.theme(for: .current))
        }
    }
    
    override open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
        if let header = view as? CollectionViewFormHeaderView {
            header.separatorColor = iOSStandardSeparatorColor
        }
    }
    
    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            // Update title view based on new traits
            if let subtitle = self.callsignListViewModel?.navSubtitle() {
                self.setTitleView(title: self.viewModel.navTitle(), subtitle: subtitle)
            }
        }, completion: nil)
    }
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if let bookOnViewController = callsignListViewModel?.bookOnViewControllerForItem(indexPath) {
            navigationController?.pushViewController(bookOnViewController, animated: true)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        return 64
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        callsignListViewModel?.applyFilter(withText: searchText)
    }
}
