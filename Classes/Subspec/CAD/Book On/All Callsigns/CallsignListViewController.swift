//
//  CallsignListViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 19/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CallsignListViewController: CADFormCollectionViewController<CallsignListItemViewModel>, UISearchBarDelegate {

    /// Layout sizing constants
    public struct LayoutConstants {
        static let searchBarHeight: CGFloat = 64
    }
    
    // MARK: - Views
    
    open var toolBar: UIToolbar!
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
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        if let subtitle = callsignListViewModel?.navSubtitle() {
            setTitleView(title: viewModel.navTitle(), subtitle: subtitle)
        }
    }
    
    open override func loadView() {
        super.loadView()
        collectionViewTopConstraint?.constant = LayoutConstants.searchBarHeight
    }

    /// Creates and styles views
    open func setupViews() {
        edgesForExtendedLayout = []
        
        // Replace default back button with 'Back'
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(goBack))
        
        toolBar = UIToolbar()
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolBar)
        
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = NSLocalizedString("Search", comment: "Search Text Placeholder")
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
    }

    /// Activates view constraints
    open func setupConstraints() {
        NSLayoutConstraint.activate([
            toolBar.topAnchor.constraint(equalTo: view.topAnchor),
            toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolBar.heightAnchor.constraint(equalToConstant: LayoutConstants.searchBarHeight),
            
            searchBar.topAnchor.constraint(equalTo: view.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: LayoutConstants.searchBarHeight)
        ])
    }
    
    @objc open func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Override
    
    override open func cellType() -> CollectionViewFormCell.Type {
        return CollectionViewFormSubtitleCell.self
    }
    
    override open func decorate(cell: CollectionViewFormCell, with viewModel: CallsignListItemViewModel) {
        cell.highlightStyle = .fade
        cell.selectionStyle = .fade
        cell.separatorStyle = .indented
        cell.separatorColor = UIColor.red
        cell.accessoryView = FormAccessoryView(style: .disclosure)
        
        if let cell = cell as? CollectionViewFormSubtitleCell {
            cell.titleLabel.text = viewModel.title
            cell.subtitleLabel.text = viewModel.subtitle
            cell.imageView.image = viewModel.image?.withRenderingMode(.alwaysTemplate)
            cell.imageView.tintColor = viewModel.imageColor
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let cell = cell as? CollectionViewFormCell {
            cell.separatorColor = iOSStandardSeparatorColor
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
        // TODO: present details?
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        if let item = viewModel.item(at: indexPath) {
            return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: item.title, subtitle: item.subtitle, inWidth: itemWidth, compatibleWith: traitCollection)
        }
        return 0
    }
    
    @objc open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormHeaderView.minimumHeight
    }

    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        callsignListViewModel?.applyFilter(withText: searchText)
    }
}
