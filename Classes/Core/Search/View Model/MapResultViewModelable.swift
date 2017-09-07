//
//  MapResultViewModelable.swift
//  MPOLKit
//
//  Created by KGWH78 on 6/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MapKit

public protocol MapResultViewModelDelegate: class {

    /// Implement to receive notification when there are changes to the results.
    ///
    /// - Parameter viewModel: The view model that is executing the method.
    func mapResultViewModelDidUpdateResults(_ viewModel: MapResultViewModelable)

}

public protocol MapResultViewModelable: SearchResultModelable {

    init()

    /// A delegate that will be notified when there are changes to the results.
    weak var delegate: MapResultViewModelDelegate? { get set }

    /// Fetch results with the given parameters.
    ///
    /// - Parameter parameters: Dictionary containing look up information.
    func fetchResults(withParameters parameters: Parameterisable)

    /// Fetch results with the given coordinate.
    ///
    /// - Parameter coordinate: Look up coordinate.
    func fetchResults(withCoordinate coordinate: CLLocationCoordinate2D)

}

/// TODO: - A default map summary search result view model.
public final class MapSummarySearchResultViewModel: MapResultViewModelable {

    public var title: String = "Temporary Title"

    public var status: SearchState? = .idle

    public weak var delegate: MapResultViewModelDelegate?

    public init() { }

    public func fetchResults(withParameters parameters: Parameterisable) {
        // TODO - Implement fetch and notify the delegate
    }

    public func fetchResults(withCoordinate coordinate: CLLocationCoordinate2D) {
        // TODO - Implement fetch and notify the delegate
    }

}
