//
//  SearchResultsListViewController.swift
//  MPOL
//
//  Created by Rod Brown on 5/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import Unbox

fileprivate let alertCellID = "alertCell"

public class SearchResultsListViewController: FormBuilderViewController, SearchResultViewModelDelegate {

    private enum CellIdentifier: String {
        case empty   = "SearchResultsViewControllerEmpty"
        case loading = "SearchResultsViewControllerLoading"
    }
    
    public var viewModel: SearchResultViewModelable? {
        didSet {
            viewModel?.style       = wantsThumbnails ? .grid : .list
            viewModel?.delegate    = self

            if isViewLoaded {
                searchFieldButton?.text = viewModel?.title

                reloadForm()
                
                updateBarItems()
                updateSearchText()
            }
        }
    }
    
    public weak var delegate: SearchResultsDelegate?

    private var wantsThumbnails: Bool = true {
        didSet {
            if wantsThumbnails == oldValue { return }

            listStateItem.image = AssetManager.shared.image(forKey: wantsThumbnails ? .list : .thumbnail)

            viewModel?.style = wantsThumbnails ? .grid : .list
            
            if traitCollection.horizontalSizeClass != .compact {
                reloadForm()
            }
        }
    }

    private let listStateItem = UIBarButtonItem(image: AssetManager.shared.image(forKey: .list), style: .plain, target: nil, action: nil)

    private var searchFieldButton: SearchFieldButton?

    public override init() {
        super.init()

        title = NSLocalizedString("Search Results", comment: "Search Results - Navigation Bar Title")

        formLayout.itemLayoutMargins = UIEdgeInsets(top: 16.5, left: 8.0, bottom: 14.5, right: 8.0)
        formLayout.distribution = .none

        listStateItem.target = self
        listStateItem.action = #selector(toggleThumbnails)
        listStateItem.imageInsets = .zero

        navigationItem.leftBarButtonItem = UIBarButtonItem.backBarButtonItem(target: self, action: #selector(backButtonItemDidSelect))
        navigationItem.rightBarButtonItems = [listStateItem]
    }


    // MARK: - View lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        let searchFieldButton = SearchFieldButton(frame: .zero)
        searchFieldButton.text = viewModel?.title
        searchFieldButton.translatesAutoresizingMaskIntoConstraints = false
        searchFieldButton.titleLabel?.font = .systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        searchFieldButton.addTarget(self, action: #selector(searchFieldButtonDidSelect), for: .primaryActionTriggered)
        view.addSubview(searchFieldButton)
        self.searchFieldButton = searchFieldButton

        NSLayoutConstraint.activate([
            searchFieldButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchFieldButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Due to use of additional safe area insets, we cannot position the top of the
            // searchFieldButton within the safe area in iOS 11, it needs to go above
            constraintAboveSafeAreaOrBelowTopLayout(searchFieldButton)
        ])

        updateBarItems()
        updateSearchText()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11, *) {
            additionalSafeAreaInsets.top = searchFieldButton?.frame.height ?? 0.0
        } else {
            legacy_additionalSafeAreaInsets.top = searchFieldButton?.frame.height ?? 0.0
        }

    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        let isCompact = traitCollection.horizontalSizeClass == .compact
        if isCompact != (previousTraitCollection?.horizontalSizeClass == .compact) {
            if wantsThumbnails {
                reloadForm()
            }
            navigationItem.rightBarButtonItems = isCompact ? nil : [listStateItem]
        }
    }

    public override func apply(_ theme: Theme) {
        super.apply(theme)
        
        guard let searchField = searchFieldButton else { return }
        
        searchField.backgroundColor = theme.color(forKey: .searchFieldBackground)
        searchField.fieldColor = theme.color(forKey: .searchField)

        // TODO: - Fix me
        searchField.textColor  = .black // primaryTextColor
        searchField.placeholderTextColor = .gray // placeholderTextColor
    }

    public override func construct(builder: FormBuilder) {
        guard let viewModel = viewModel else { return }
        builder += viewModel.results.flatMap { viewModel.itemsForResultsInSection($0) }
    }

    // MARK: - CollectionViewDelegateFormLayout methods

//    public override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, insetForSection section: Int) -> UIEdgeInsets {
//        var inset = super.collectionView(collectionView, layout: layout, insetForSection: section)
//        inset.top    = 4.0
//        inset.bottom = 0
//        return inset
//    }

    public func requestToEdit() {
        delegate?.searchResultsControllerDidRequestToEdit(self)
    }

    // MARK: - SearchResultRendererDelegate
    
    public func searchResultViewModelDidUpdateResults(_ viewModel: SearchResultViewModelable) {
        updateBarItems()
        updateSearchText()
        reloadForm()
    }

    public func searchResultViewModel(_ viewModel: SearchResultViewModelable, didSelectEntity entity: MPOLKitEntity) {
        delegate?.searchResultsController(self, didSelectEntity: entity)
    }

    // MARK: - Private methods

    @objc private func searchFieldButtonDidSelect() {
        delegate?.searchResultsControllerDidRequestToEdit(self)
    }

    @objc private func backButtonItemDidSelect() {
        delegate?.searchResultsControllerDidCancel(self)
    }

    @objc private func toggleThumbnails() {
        wantsThumbnails = !wantsThumbnails
    }

    private func updateSearchText() {
        let label = RoundedRectLabel(frame: CGRect(x: 10, y: 10, width: 120, height: 16))
        label.backgroundColor = .clear
        label.borderColor = viewModel?.status?.colour
        label.textColor = viewModel?.status?.colour
        label.text = viewModel?.status?.searchText
        label.cornerRadius = 2.0
        label.sizeToFit()

        searchFieldButton?.accessoryView = label
    }
    
    private func updateBarItems() {
        if var buttons = viewModel?.additionalBarButtonItems {
            buttons.append(listStateItem)
            navigationItem.rightBarButtonItems = buttons
        } else {
            navigationItem.rightBarButtonItems = [listStateItem]
        }
    }
}

/// A delegate to notify that an entity was selected
public protocol EntityDetailsDelegate: class {

    /// Notify the delegate that an entity was selected
    ///
    /// - Parameters:
    ///   - controller: the controller that the entity was selected on
    ///   - entity: the entity that was selected
    func controller(_ controller: UIViewController, didSelectEntity entity: MPOLKitEntity)

    func controller(_ controller: UIViewController, searchFor searchable: Searchable)
}

public protocol SearchResultsDelegate: class {
    func searchResultsControllerDidRequestToEdit(_ controller: UIViewController)
    func searchResultsController(_ controller: UIViewController, didSelectEntity entity: MPOLKitEntity)
    func searchResultsControllerDidCancel(_ controller: UIViewController)
}


