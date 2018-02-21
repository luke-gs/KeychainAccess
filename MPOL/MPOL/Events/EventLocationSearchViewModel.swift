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
        case .manual: return "Enter location manually"
        case .map: return "Search on map"
        case .current: return "Current location"
        }
    }

    static let defaultOptions: [EventLocationSearchOption] = [.current, .map, .manual]
}

class EventLocationSearchViewModel<T: EventSearchableViewModelDelegate>: EventSearchableViewModel where T.Searchable == LookupAddress, T.Option == EventLocationSearchOption {
    typealias Searchable = LookupAddress
    typealias Option = EventLocationSearchOption

    let title: String
    private var cancelToken: PromiseCancellationToken = PromiseCancellationToken()
    private let plugin = TravelEstimationPlugin()

    var delegate: T?
    var recentLocationDisplayables: [LookupAddress]
    var searchResults: [LookupAddress] = [] {
        didSet {
            defaultOptions = searchResults.count > 0 ? formItems(for: [.manual]) : formItems(for: EventLocationSearchOption.defaultOptions)
            delegate?.didUpdateDatasource()
        }
    }

    init(title: String = "Select location", recentLocations: [LookupAddress]) {
        recentLocationDisplayables = recentLocations
        self.title = title
    }

    private lazy var defaultOptions: [SubtitleFormItem] = formItems(for: EventLocationSearchOption.defaultOptions)

    public func construct(builder: FormBuilder) {
        builder.forceLinearLayout = true
        builder.forceLinearLayoutWhenCompact = true

        if searchResults.count > 0 {
            builder += HeaderFormItem(text: "\(searchResults.count) RESULT\(searchResults.count == 0 ? "" : "S") FOUND", style: .collapsible)
            builder += searchResults.map { address in
                SubtitleFormItem(title: address.fullAddress, subtitle: "Calculating", image: AssetManager.shared.image(forKey: .location), style: .default)
                    .accessory(ItemAccessory.disclosure)
                    .onSelection { _ in
                        self.delegate?.didSelectSearchable(address)
                    }
                    .onConfigured({ cell in

                        // TODO: need to do this better

                        let cell = cell as! CollectionViewFormSubtitleCell
                        let destination = CLLocation(latitude: address.coordinate.latitude, longitude: address.coordinate.longitude)

                        DispatchQueue.global(qos: .userInteractive).async {
                            _ = LocationManager.shared.requestLocation().then {
                                self.plugin.calculateDistance(from: $0, to: destination).then { value in
                                    DispatchQueue.main.async {
                                        cell.subtitleLabel.text = value
                                    }
                                }
                            }
                        }
                    })
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

    private func formItems(for options: [EventLocationSearchOption]) -> [SubtitleFormItem] {
        return options.map { option in
            SubtitleFormItem(title: option.title, image: AssetManager.shared.image(forKey: .location))
                .accessory(ItemAccessory.disclosure)
                .onSelection { _ in
                    self.delegate?.didSelectOption(option)
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
                .then {
                    self.searchResults = $0
                }.catch(on: .main, policy: CatchPolicy.allErrors, execute: { (error) in
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
