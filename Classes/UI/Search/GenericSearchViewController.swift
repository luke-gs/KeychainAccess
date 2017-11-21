//
//  GenericSearchViewController.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class GenericSearchViewController: FormBuilderViewController, UISearchBarDelegate {

    /// The delegate for the collection view touches
    public var delegate: GenericSearchDelegate?

    public let viewModel: GenericSearchViewModel

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.autoresizingMask = [.flexibleWidth]
        searchBar.sizeToFit()
        return searchBar
    }()
    
    public required init(viewModel: GenericSearchViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(searchBar)
        updateColour(for: traitCollection)
    }

    override open func construct(builder: FormBuilder) {
        builder.forceLinearLayout = true
        builder.title = viewModel.title

        for section in 0..<viewModel.numberOfSections() {
            if viewModel.hasSections == true && viewModel.isSectionHidden(section) == false {
                builder += HeaderFormItem(text: viewModel.title(for: section))
            }
            for row in 0..<viewModel.numberOfRows(in: section) {
                let indexPath = IndexPath(row: row, section: section)
                var accessory : ItemAccessory? = nil
                if viewModel.selectedItem(item: viewModel.searchable(for: indexPath)) == true {
                    accessory = .checkmark
                }

                builder += SubtitleFormItem(title: viewModel.title(for: indexPath),
                                            subtitle: viewModel.description(for: indexPath),
                                            image: viewModel.image(for: indexPath),
                                            style: .default)
                    .accessory(accessory)
                    .onSelection { [unowned self] cell in
                        let searchable = self.viewModel.searchable(for: indexPath)
                        self.delegate?.genericSearchViewController(self, didSelectRowAt: indexPath, withSearchable: searchable)
                }
            }
        }
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if #available(iOS 11.0, *) {
            searchBar.frame.origin.y = self.view.safeAreaInsets.top - searchBar.frame.height
            additionalSafeAreaInsets.top = searchBar.frame.height
        } else {
            searchBar.frame.origin.y = topLayoutGuide.length
            legacy_additionalSafeAreaInsets.top = searchBar.frame.size.height
        }
    }

    private func updateColour(for traitCollection: UITraitCollection) {
        let shouldBeWhite = traitCollection.horizontalSizeClass == .compact || !self.isBeingPresented
        view.backgroundColor = shouldBeWhite ? .white : UIColor.white.withAlphaComponent(0.64)
    }


    // MARK: Searchbar delegate

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if viewModel.items.isEmpty {
            loadingManager.state = .noContent
        } else {
            loadingManager.state = .loaded
        }
        viewModel.searchTextChanged(to: searchText)
        reloadForm()
    }

    // MARK: Traits

    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updateColour(for: newCollection)
    }
}

/// The generic search delegate
public protocol GenericSearchDelegate {

    /// Called when a row of the collection view is tapped
    ///
    /// - Parameters:
    ///   - viewController: the view controller that the tap came form
    ///   - indexPath: the indexPath that was tapped
    ///   - withSearchable: teh searchable object for that indexPath
    func genericSearchViewController(_ viewController: GenericSearchViewController, didSelectRowAt indexPath: IndexPath, withSearchable: GenericSearchable)
}
