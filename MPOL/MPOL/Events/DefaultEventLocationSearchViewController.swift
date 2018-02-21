//
//  DefaultEventLocationSearchViewController.swift
//  MPOL
//
//  Created by QHMW64 on 19/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit
import PromiseKit

class EventLocationSearchViewController: FormBuilderSearchViewController, EventSearchableViewModelDelegate, CLLocationManagerDelegate {

    typealias Option = EventLocationSearchOption
    typealias Searchable = LookupAddress

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        return activityIndicator
    }()

    let viewModel: EventLocationSearchViewModel<EventLocationSearchViewController>
    let locationManager: CLLocationManager = CLLocationManager()
    let selectionViewModel: LocationSelectionViewModel

    init(viewModel: EventLocationSearchViewModel<EventLocationSearchViewController>, selectionViewModel: LocationSelectionViewModel) {
        self.viewModel = viewModel
        self.selectionViewModel = selectionViewModel
        super.init()
        viewModel.delegate = self
        title = viewModel.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped(sender:)))

        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    @objc private func cancelTapped(sender: UIBarButtonItem) {
        dismissAnimated()
    }

    override func construct(builder: FormBuilder) {
        viewModel.construct(builder: builder)
    }

    // MARK: Searchbar delegate

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.didCancelSearch()
        
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchTextDidChange(to: searchText)
        if searchText.count > 0 {
            activityIndicator.startAnimating()
        }
    }

    // MARK: - Event Location Search Delegate

    func didUpdateDatasource() {
        reloadForm()
        activityIndicator.stopAnimating()
    }

    func didSelectSearchable(_ searchable: LookupAddress) {
        selectionViewModel.location = EventLocation(location: searchable.coordinate, addressString: searchable.fullAddress)
        selectionViewModel.dropsPinAutomatically = true
        let viewController = LocationMapSelectionViewController(viewModel: selectionViewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func didSelectOption(_ option: EventLocationSearchOption) {
        // TODO: - Implement the manual selection later once
        // creative has been updated
        guard let location = locationManager.location, option != .manual else { return }

        if option == .current {
            selectionViewModel.dropsPinAutomatically = true
            selectionViewModel.location = EventLocation(location: location.coordinate, addressString: nil)
        }
        let viewController = LocationMapSelectionViewController(viewModel: selectionViewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
