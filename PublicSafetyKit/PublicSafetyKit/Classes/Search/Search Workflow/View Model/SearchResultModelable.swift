//
//  SearchResultModelable.swift
//  MPOLKit
//
//  Created by KGWH78 on 6/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public protocol SearchResultModelable: class {

    /// The text that represents the search query.
    ///
    /// This is typically the text that the user enters when searching.
    /// For example, "Smith Johnson" or "ABBC123"
    ///
    /// However, the subclass can provide a custom formatted text if required.
    var title: String { get }

    /// The current status of the search.
    ///
    /// Used to indicate the progress of the current search status. This is shown
    /// on the right of the search bar.
    var status: SearchState? { get }

}
