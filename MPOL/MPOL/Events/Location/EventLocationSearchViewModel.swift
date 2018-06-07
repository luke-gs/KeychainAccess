//
//  EventLocationSearchViewModel.swift
//  MPOL
//
//  Created by QHMW64 on 21/2/18.
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
        case .manual: return "Enter Location Manually"
        case .map: return "Search on Map"
        case .current: return "Current Location"
        }
    }

    var image: UIImage? {
        switch self {
        case .current: return AssetManager.shared.image(forKey: .mapUserLocation)
        case .manual: return AssetManager.shared.image(forKey: .editCell)
        case .map: return AssetManager.shared.image(forKey: .map)
        }
    }

    static let defaultOptions: [EventLocationSearchOption] = [.current, .map, .manual]
}

class EventLocationSearchViewModel<T: EventSearchableViewModelDelegate>: NSObject, EventSearchableViewModel, CLLocationManagerDelegate where T.Searchable == LookupAddress, T.Option == EventLocationSearchOption {

    typealias Searchable = LookupAddress
    typealias Option = EventLocationSearchOption

    let title: String
    private var cancelToken: PromiseCancellationToken = PromiseCancellationToken()
    private let travelPlugin = TravelEstimationPlugin()

    var delegate: T?
    var recentLocationDisplayables: [LookupAddress]
    var searchResults: [LookupAddress] = [] {
        didSet {
            oldValue.forEach {
                itemMap.removeValue(forKey: $0.coordinate)
            }

            defaultOptions = searchResults.count > 0 ? formItems(for: [.manual]) : formItems(for: EventLocationSearchOption.defaultOptions)
            delegate?.didUpdateDatasource()
        }
    }

    private var itemMap: [CLLocationCoordinate2D: SubtitleFormItem] = [:]

    private let locationManager: CLLocationManager = CLLocationManager()

    init(title: String = "Select Location", recentLocations: [LookupAddress]) {
        recentLocationDisplayables = recentLocations
        self.title = title

        locationManager.startUpdatingLocation()
    }

    private lazy var defaultOptions: [SubtitleFormItem] = formItems(for: EventLocationSearchOption.defaultOptions)

    public func construct(builder: FormBuilder) {
        builder.forceLinearLayout = true
        builder.forceLinearLayoutWhenCompact = true

        if searchResults.count > 0 {
            builder += HeaderFormItem(text: "\(searchResults.count) RESULT\(searchResults.count == 0 ? "" : "S") FOUND", style: .collapsible)
            builder += searchResults.map { address in
                let item = SubtitleFormItem(title: address.fullAddress, subtitle: "Calculating", image: AssetManager.shared.image(forKey: .location), style: .default)
                    .accessory(ItemAccessory.disclosure)
                    .onSelection { _ in
                        self.delegate?.didSelectSearchable(address)
                    }

                if let userLocation = locationManager.location {
                    let addressLocation = CLLocation(latitude: address.coordinate.latitude, longitude: address.coordinate.longitude)
                    updateDistance(item, fromLocation: userLocation, toLocation: addressLocation)
                }
                itemMap[address.coordinate] = item
                return item
            }
        }
        builder += HeaderFormItem(text: "OPTIONS", style: .plain)
        builder += defaultOptions
        builder += HeaderFormItem(text: "RECENTLY USED/SEARCHED", style: .plain)
        builder += recentLocationDisplayables.map { address in
            SubtitleFormItem(title: address.fullAddress, image: AssetManager.shared.image(forKey: .location), style: .default)
                .subtitle("Calculating")
                .accessory(ItemAccessory.disclosure)
                .onSelection { _ in
                    self.delegate?.didSelectSearchable(address)
            }
        }
    }

    private func updateDistance(_ item: SubtitleFormItem, fromLocation location: CLLocation, toLocation: CLLocation) {
        travelPlugin.calculateDistance(from: location, to: toLocation).done { [weak item] text -> Void in
            item?.subtitle(text).reloadItem()
        }.catch { _ in
            item.subtitle("Unknown").reloadItem()
        }
    }

    private func formItems(for options: [EventLocationSearchOption]) -> [SubtitleFormItem] {
        return options.map { option in
            SubtitleFormItem(title: option.title, image: option.image?.withRenderingMode(.alwaysTemplate))
                .accessory(ItemAccessory.disclosure)
                .onSelection { _ in
                    self.delegate?.didSelectOption(option)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.first else { return }
        itemMap.forEach { location, item in
            let destination = CLLocation(latitude: location.latitude, longitude: location.longitude)
            travelPlugin.calculateDistance(from: userLocation, to: destination).done { [weak item] text -> Void in
                item?.subtitle(text).reloadItem()
            }.catch { [weak item] (error) in
                item?.subtitle(NSLocalizedString("Unknown", comment: "")).reloadItem()
            }
        }
    }

    func didCancelSearch() {
        delegate?.didUpdateDatasource()
    }

    func searchTextDidChange(to text: String?) {
        if let text = text?.ifNotEmpty() {
            // Cancel existing request
            self.cancelToken.cancel()
            let cancelToken = PromiseCancellationToken()

            APIManager.shared.typeAheadSearchAddress(in: MPOLSource.gnaf, with: LookupAddressSearchRequest(searchText: text), withCancellationToken: cancelToken)
                .done {
                    self.searchResults = $0
                }.catch(on: .main, policy: CatchPolicy.allErrors, { (error) in
                    print(error)
                })
            self.cancelToken = cancelToken
        } else {
            // Handle when the text is cleared by deletion
            searchResults = []
        }
        delegate?.didUpdateDatasource()
    }

}
