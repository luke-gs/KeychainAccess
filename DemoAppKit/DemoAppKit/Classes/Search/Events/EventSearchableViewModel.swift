//
//  EventSearchableViewModel.swift
//  MPOLKit
//
//  Created by QHMW64 on 21/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol EventSearchableViewModel {
    associatedtype Searchable

    var title: String { get }
    var searchResults: [Searchable] { get set }

    func construct(builder: FormBuilder)
    func searchTextDidChange(to text: String?)
    func didCancelSearch()
}

public protocol EventSearchableViewModelDelegate: class {
    associatedtype Searchable
    associatedtype Option

    func didUpdateDataSource()
    func didSelectSearchable(_ searchable: Searchable)
    func didSelectOption(_ option: Option)
}
