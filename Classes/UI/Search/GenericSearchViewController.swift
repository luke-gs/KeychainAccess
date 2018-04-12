//
//  GenericSearchViewController.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

open class SearchDisplayableViewController<T: SearchDisplayableDelegate, U: SearchDisplayableViewModel>: FormBuilderViewController, UISearchBarDelegate where T.Object == U.Object {

    /// The delegate for the collection view touches
    public var delegate: T?
    public let viewModel: U

    // Search bar in a container view
    public let searchBarView = StandardSearchBarView(frame: .zero)

    public required init(viewModel: U) {
        self.viewModel = viewModel
        super.init()
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        searchBarView.searchBar.delegate = self
        view.addSubview(searchBarView)

        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
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

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets.top = searchBarView.frame.height
            searchBarView.frame.origin.y = view.safeAreaInsets.top - searchBarView.frame.height
        } else {
            legacy_additionalSafeAreaInsets.top = searchBarView.frame.height
            searchBarView.frame.origin.y = topLayoutGuide.length
        }
        // Update layout if safe area changed constraints
        view.layoutIfNeeded()
    }

    // MARK: Searchbar delegate

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchTextChanged(to: searchText)
        reloadForm()
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let action = viewModel.searchAction() else { return }
        action.then {
            self.reloadForm()
        }.catch { _ in
            self.loadingManager.state = .error
        }
    }

}

/// The generic search delegate
public protocol SearchDisplayableDelegate {

    associatedtype Object

    /// Called when a row of the collection view is tapped
    ///
    /// - Parameters:
    ///   - viewController: the view controller that the tap came form
    ///   - indexPath: the indexPath that was tapped
    ///   - withSearchable: teh searchable object for that indexPath
    func genericSearchViewController(_ viewController: UIViewController, didSelectRowAt indexPath: IndexPath, withObject object: Object)
}
