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

enum EventLocationSearchOption {
    case manual
    case map
    case current

    var title: String {
        switch self {
        case .manual: return "Enter location manually"
        case .map: return "Search on map"
        case .current: return "Current location"
        }
    }

    static let defaultOptions: [EventLocationSearchOption] = [.current, .map, .manual]


}

protocol EventLocationSearchViewModelDelegate {
    func viewModelDidUpdate(_ viewModel: EventLocationSearchViewModel)
    func viewModel(_ viewModel: EventLocationSearchViewModel, didSelectLocation location: AddressSummaryDisplayable)
    func viewModel(_ viewModel: EventLocationSearchViewModel, didSelectOption option: EventLocationSearchOption)
}

class EventLocationSearchViewModel {

    let title: String
    private let cancelToken: PromiseCancellationToken = PromiseCancellationToken()

    var delegate: EventLocationSearchViewModelDelegate?
    var recentLocationDisplayables: [AddressSummaryDisplayable]
    var searchResults: [AddressSummaryDisplayable] = [] {
        didSet {
            defaultOptions = searchResults.count > 0 ? formItems(for: [.manual]) : formItems(for: EventLocationSearchOption.defaultOptions)

            delegate?.viewModelDidUpdate(self)
        }
    }

    init(title: String = "Select location", recentLocations: [AddressSummaryDisplayable]) {
        recentLocationDisplayables = recentLocations
        self.title = title
    }

    private lazy var defaultOptions: [SubtitleFormItem] = formItems(for: EventLocationSearchOption.defaultOptions)

    public func construct(builder: FormBuilder) {
        builder.forceLinearLayout = true
        builder.forceLinearLayoutWhenCompact = true

        if searchResults.count > 0 {
            builder += HeaderFormItem(text: "\(searchResults.count) RESULT\(searchResults.count == 0 ? "" : "S") FOUND")
            builder += searchResults.map { address in
                SubtitleFormItem(title: address.title, subtitle: "4km", image: AssetManager.shared.image(forKey: .location), style: .default)
                    .accessory(ItemAccessory.disclosure)
                    .onSelection { _ in
                        self.delegate?.viewModel(self, didSelectLocation: address)
                    }
                }
        }
        builder += HeaderFormItem(text: "OPTIONS", style: .plain)
        builder += defaultOptions
        builder += HeaderFormItem(text: "RECENTLY USED/SEARCHED", style: .plain)
        builder += recentLocationDisplayables.map { address in
            SubtitleFormItem(title: address.title, subtitle: "4km", image: AssetManager.shared.image(forKey: .location), style: .default)
                .accessory(ItemAccessory.disclosure)
                .onSelection { _ in
                    self.delegate?.viewModel(self, didSelectLocation: address)
                }
        }
    }

    private func formItems(for options: [EventLocationSearchOption]) -> [SubtitleFormItem] {
        return options.map { option in
            SubtitleFormItem(title: option.title, image: AssetManager.shared.image(forKey: .location))
                .accessory(ItemAccessory.disclosure)
                .onSelection { _ in
                    self.delegate?.viewModel(self, didSelectOption: option)
            }
        }
    }

    func searchTextDidChange(to text: String?) {
        guard let text = text else { return }

        // Cancel existing request
        cancelToken.cancel()

        APIManager.shared.typeAheadSearchAddress(in: MPOLSource.mpol, with: LookupAddressSearchRequest(searchText: text))
            .always {
            self.delegate?.viewModelDidUpdate(self)
        }
    }

}

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

    // MARK: Searchbar delegate

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadForm()
    }

}

class EventLocationSearchViewController: FormBuilderSearchViewController, EventLocationSearchViewModelDelegate, CLLocationManagerDelegate {

    let viewModel: EventLocationSearchViewModel
    let locationManager: CLLocationManager = CLLocationManager()
    let selectionViewModel: LocationSelectionViewModel

    init(viewModel: EventLocationSearchViewModel, selectionViewModel: LocationSelectionViewModel) {
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

    public override func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchTextDidChange(to: searchText)
    }

    // MARK: - Event Location Search Delegate

    func viewModelDidUpdate(_ viewModel: EventLocationSearchViewModel) {
        reloadForm()
    }

    func viewModel(_ viewModel: EventLocationSearchViewModel, didSelectLocation location: AddressSummaryDisplayable) {
        let viewController = LocationMapSelectionViewController(viewModel: selectionViewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func viewModel(_ viewModel: EventLocationSearchViewModel, didSelectOption option: EventLocationSearchOption) {
        // TODO: - Implement the manual selection later once
        // creative has been updated
        guard let location = locationManager.location, option != .manual else { return }

        selectionViewModel.useCurrentLocation = option == .current
        selectionViewModel.location = EventLocation(location: location.coordinate, addressString: nil)
        let viewController = LocationMapSelectionViewController(viewModel: selectionViewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
