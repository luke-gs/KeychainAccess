//
//  FormBuilderSearchViewController.swift
//  MPOLKit
//
//  Created by QHMW64 on 21/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// A subclass of a FormBuilderViewController that simply adds a search bar above the
/// collection views contents
/// You should subclass this if you wish to use it witha custom search delegate 
open class FormBuilderSearchViewController: FormBuilderViewController, UISearchBarDelegate {

    public let searchBarView = StandardSearchBarView(frame: .zero)

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
}
