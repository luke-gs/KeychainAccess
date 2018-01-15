//
//  MPOLKitProtocols.swift
//  Pods
//
//  Created by Pavel Boryseiko on 20/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// The recent searches view controller view model (pretty much just a container)
public protocol SearchRecentsViewModel: class {

    /// The title of the view cotroller
    var title: String { get }

    /// Array of recently viewed entities
    var recentlyViewed: EntityBucket { get }

    /// Array of recently searched
    var recentlySearched: [Searchable] { get set }

    weak var delegate: (SearchRecentsViewModelDelegate & UIViewController)? { get set }

    func recentlyViewedItems() -> [FormItem]

    func recentlySearchedItems() -> [FormItem]

}

public protocol SearchRecentsViewModelDelegate: class {

    func searchRecentsViewModel(_ searchRecentsViewModel: SearchRecentsViewModel, didSelectPresentable presentable: Presentable)

    func searchRecentsViewModel(_ searchRecentsViewModel: SearchRecentsViewModel, didSelectSearchable searchable: Searchable)
    
    func searchRecentsViewModelDidChange(_ searchRecentsViewModel: SearchRecentsViewModel)

}

/// The main search view model container
///
/// Only reason this really exists is that once we pass this in to MPOLKit's main SearchViewController we don't have control over this object's properties
public protocol SearchViewModel {

    /// The recent view model
    var recentViewModel: SearchRecentsViewModel { get }

    /// The data sources to be used
    var dataSources: [SearchDataSource] { get }

}

public protocol SearchDelegate: class {

    func beginSearch(reset: Bool)

    func beginSearch(with searchable: Searchable)

    func handlePresentable(_ presentable: Presentable)

}


