//
//  LocationSearchDataSource.swift
//  MPOL
//
//  Created by KGWH78 on 21/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit
import Unbox
import MapKit


public protocol Locatable {
    var textRepresentation: String { get }
    var coordinate: CLLocationCoordinate2D { get }
}

public struct LookupResult: Pickable {
    
    public let location: Locatable
    public let title: String?
    public let subtitle: String?
    
    public init(location: Locatable) {
        self.location = location
        
        self.title    = location.textRepresentation
        self.subtitle = nil
    }
}

public let LocationSearchDataSourceSearchableType = "Location"

public class LocationSearchDataSource<T: LocationAdvancedOptions, U: LocationSearchStrategy>: NSObject, SearchDataSource, UITextFieldDelegate, LocationBasicSearchOptionsDelegate, LocationAdvancedOptionDelegate where T.Location == U.Location {

    private let searchPlaceholder = NSAttributedString(string: NSLocalizedString("eg. 28 Wellington Street", comment: ""),
                                                       attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 28.0, weight: UIFont.Weight.light), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
    
    private var additionalSearchButtons: [UIButton] {
        let helpButton = UIButton(type: .system)
        helpButton.addTarget(self, action: #selector(didTapHelpButton), for: .touchUpInside)
        helpButton.setImage(AssetManager.shared.image(forKey: .info), for: .normal)
        return [helpButton]
    }
    
    private var text: String? {
        didSet {
            errorMessage = nil
        }
    }
    
    private var errorMessage: String? {
        didSet {
            if oldValue != errorMessage {
                updatingDelegate?.searchDataSource(self, didUpdateComponent: .searchStyleErrorMessage)
            }
        }
    }

    public var searchStyle: SearchFieldStyle {
        if options is LocationBasicSearchOptions {
            return .search(configure: { [weak self] (textField) in
                guard let `self` = self else { return nil }
                
                textField.text                   = self.text
                textField.keyboardType           = .asciiCapable
                textField.autocapitalizationType = .words
                textField.autocorrectionType     = .no
                textField.returnKeyType          = .search
                textField.attributedPlaceholder  = self.searchPlaceholder
                
                return self.additionalSearchButtons
            }, textHandler: self.searchTextDidChange, errorMessage: self.errorMessage)
        } else {
            return .button(configure: { [weak self] (button) in
                guard let `self` = self, let advanceOptions = self.advanceOptions else { return }
                
                button.setTitle(advanceOptions.cancelTitle, for: .normal)
                
                if button.actions(forTarget: self, forControlEvent: .touchUpInside) == nil {
                    button.addTarget(self, action: #selector(self.didTapSimpleSearchButton), for: .touchUpInside)
                }
            })
        }
    }
    
    private lazy var searchButton: UIBarButtonItem? = UIBarButtonItem(title: NSLocalizedString("Search", comment: ""), style: .done, target: self, action: #selector(didTapSearchButton))

    public var navigationButton: UIBarButtonItem? {
        return options is LocationBasicSearchOptions ? nil : searchButton
    }
    
    public var options: SearchOptions? {
        didSet {
            updatingDelegate?.searchDataSource(self, didUpdateComponent: .all)
        }
    }

    private let basicOptions = LocationBasicSearchOptions()
    public let advanceOptions: T?
    public let searchStrategy: U

    public weak var updatingDelegate: SearchDataSourceUpdating?
    
    public var localizedDisplayName: String {
        return NSLocalizedString("Location", comment: "")
    }
    
    public init(strategy: U, advanceOptions: T) {
        self.searchStrategy = strategy
        self.advanceOptions = advanceOptions
        
        super.init()

        if searchStrategy.resultModelForMap() == nil {
            basicOptions.others = [.advance]
        }

        self.advanceOptions?.delegate = self
        basicOptions.delegate = self
        options = basicOptions
    }
    
    public func selectionAction(forFilterAt index: Int) -> SearchOptionAction {
        if let options = options as? T {
            let updateHandler = { [weak self] in
                guard let `self` = self else { return }
                self.updatingDelegate?.searchDataSource(self, didUpdateComponent: .filter(index: index))
            }
            
            if let controller = options.pickerController(forFilterAt: index, updateHandler: updateHandler) {
                return .options(controller: controller)
            }
        } else if let options = options as? LocationBasicSearchOptions {
            switch options.resultType(at: index) {
            case .lookup:
                performSearchOnLocation(withResult: options.results[index])
            case .advance:
                didTapAdvanceButton()
            case .map:
                didTapMapButton()
            }
        }
        
        return .none
    }
    
    public func textChanged(forFilterAt index: Int, text: String?, didEndEditing ended: Bool) {
        if let options = options as? T {
            options.populate(withOptions: [index: text ?? ""], reset: false)
            updatingDelegate?.searchDataSource(self, didUpdateComponent: .filterErrorMessage(index: index))
        }
    }
    
    public func prefill(withSearchable searchable: Searchable) -> Bool {
        let type = searchable.type
        
        if type == nil {
            text = searchable.text
            attemptSearch(delay: !(text?.isEmpty ?? true))
            
            basicOptions.reset()
            advanceOptions?.populate(withOptions: nil, reset: true)
            
            options = basicOptions
            return true
        } else if type == LocationSearchDataSourceSearchableType {
            
            basicOptions.reset()
            advanceOptions?.populate(withOptions: nil, reset: true)
            
            if let lastOptions = searchable.options {
                text = nil
                advanceOptions?.populate(withOptions: lastOptions, reset: true)
                options = advanceOptions
            } else {
                text = searchable.text
                attemptSearch(delay: !(text?.isEmpty ?? true))
                options = basicOptions
            }
            return true
        }

        return false
    }
    
    // MARK: - Private
    
    @objc private func didTapHelpButton() {
        (self.updatingDelegate as? UIViewController)?.present(searchStrategy.helpPresentable)
    }
    
    @objc private func didTapSimpleSearchButton() {
        options = basicOptions
    }
    
    @objc private func didTapAdvanceButton() {
        options = advanceOptions
    }
    
    @objc private func didTapSearchButton() {
        guard let advanceOptions = advanceOptions else { return }
        performSearchOnLocation(withParameters: advanceOptions.locationParameters())
    }
    
    @objc private func didTapMapButton() {
        let preferredViewModel = searchStrategy.resultModelForMap()
        updatingDelegate?.searchDataSource(self, didFinishWith: nil, andResultViewModel: preferredViewModel)
    }
    
    private func attemptSearch(delay: Bool = true) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(lookupLocations), object: nil)
        self.perform(#selector(lookupLocations), with: nil, afterDelay: delay ? searchStrategy.configuration.throttle : 0.0)
    }
    
    private var lastSearchText: String?
    
    @objc private func lookupLocations() {
        guard let text = text, text.count >= searchStrategy.configuration.minimumCharacters else {
            lastSearchText = nil
            errorMessage = nil

            if basicOptions.results.count != 0 {
                basicOptions.results = []
                updatingDelegate?.searchDataSource(self, didUpdateComponent: .filter(index: nil))
            }

            return
        }
        
        if let promise = self.searchStrategy.locationTypeaheadPromise(text: text) {
            lastSearchText = text
            errorMessage = nil

            promise.then { [weak self] locations -> () in
                guard let `self` = self, self.lastSearchText == text else { return }
                
                if locations.isEmpty {
                    self.errorMessage = "No results found for '\(text)'."
                    self.basicOptions.results = []
                } else {
                    let results = locations.map { LookupResult(location: $0) }
                    self.basicOptions.results = results
                }

                self.updatingDelegate?.searchDataSource(self, didUpdateComponent: .filter(index: nil))
            }.catch { [weak self] in
                guard let `self` = self, self.lastSearchText == text else { return }
                    
                let error = $0 as? MappedError
                self.errorMessage = error?.localizedDescription
            }
        }
    }

    // MARK: - Advanced Search Delegate

    public func locationAdvancedOptionsDidUpdate() {
        if let advancedOptions = advanceOptions {
            let canPerformSearch = advancedOptions.canPeformSearch()
            searchButton?.isEnabled = canPerformSearch
        }
    }

    // MARK: - Search text handling
    
    private func searchTextDidChange(_ text: String?, _ endEditing: Bool) {
        self.text = text

        attemptSearch(delay: !endEditing)
    }

    // MARK: - Handle address
    
    private func performSearchOnLocation(withResult result: LookupResult) {
        text = result.location.textRepresentation
        let search = Searchable(text: text,
                                options: nil,
                                type: LocationSearchDataSourceSearchableType)

        let preferredViewModel = searchStrategy.resultModelForSearchOnLocation(withResult: result, andSearchable: search)
        let radiusSearch = LocationMapSearchType.radiusSearch(from: result.location.coordinate)
        // preferredViewModel.fetchResults(with: radiusSearch)

        updatingDelegate?.searchDataSource(self, didFinishWith: search, andResultViewModel: preferredViewModel)
    }
    
    private func performSearchOnLocation(withParameters parameters: Parameterisable) {
        guard let advanceOptions = advanceOptions else { return }

        let search = Searchable(text: advanceOptions.textRepresentation(),
                                options: advanceOptions.state(),
                                type: LocationSearchDataSourceSearchableType)

        let preferredViewModel = searchStrategy.resultModelForSearchOnLocation(withParameters: parameters, andSearchable: search)
        updatingDelegate?.searchDataSource(self, didFinishWith: search, andResultViewModel: preferredViewModel)
    }
    
    public func locationBasicSearchOptions(_ options: LocationBasicSearchOptions, didEditResult result: LookupResult) {
        guard let advanceOptions = advanceOptions else { return }

        advanceOptions.populate(withLocation: result.location as! T.Location)
        self.options = advanceOptions
    }
}

