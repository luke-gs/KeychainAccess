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


extension LookupAddress: Pickable {
    public var title: String? { return fullAddress }
    public var subtitle: String? { return "0 m" }
}

public class LocationSearchDataSource: NSObject, SearchDataSource, UITextFieldDelegate, LocationBasicSearchOptionsDelegate {
    
    public static let searchableType = "Location"
    
    private let searchPlaceholder = NSAttributedString(string: NSLocalizedString("eg. 28 Wellington Street", comment: ""),
                                                       attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 28.0, weight: UIFontWeightLight), NSForegroundColorAttributeName: UIColor.lightGray])
    
    private var additionalSearchButtons: [UIButton] {
        let mapButton = UIButton(type: .system)
        mapButton.addTarget(self, action: #selector(didTapMapButton), for: .touchUpInside)
        mapButton.setImage(AssetManager.shared.image(forKey: .location), for: .normal)
        
        let helpButton = UIButton(type: .system)
        helpButton.addTarget(self, action: #selector(didTapHelpButton), for: .touchUpInside)
        helpButton.setImage(AssetManager.shared.image(forKey: .info), for: .normal)
        return [mapButton, helpButton]
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
                guard let `self` = self else { return }
                
                button.setTitle(self.advanceOptions.cancelTitle, for: .normal)
                
                if button.actions(forTarget: self, forControlEvent: .touchUpInside) == nil {
                    button.addTarget(self, action: #selector(self.didTapSimpleSearchButton), for: .touchUpInside)
                }
            })
        }
    }
    
    private lazy var searchButton: UIBarButtonItem? = UIBarButtonItem(title: NSLocalizedString("Search", comment: ""), style: .done, target: self, action: #selector(didTapSearchButton))
    private lazy var advanceButton: UIBarButtonItem? = UIBarButtonItem(title: NSLocalizedString("Advance Search", comment: ""), style: .done, target: self, action: #selector(didTapAdvanceButton))
    
    public var navigationButton: UIBarButtonItem? {
        return options is LocationBasicSearchOptions ? advanceButton : searchButton
    }
    
    public var options: SearchOptions? {
        didSet {
            updatingDelegate?.searchDataSource(self, didUpdateComponent: .all)
        }
    }

    private let basicOptions  = LocationBasicSearchOptions()
    public let advanceOptions: LocationAdvanceOptions

    public weak var updatingDelegate: SearchDataSourceUpdating?
    
    public var localizedDisplayName: String {
        return NSLocalizedString("Location", comment: "")
    }
    
    public let searchStrategy: LocationSearchStrategy
    
    public init(strategy: LocationSearchStrategy, advanceOptions: LocationAdvanceOptions = LocationAdvanceSearchOptions()) {
        self.searchStrategy = strategy
        self.advanceOptions = advanceOptions
        
        super.init()
        
        basicOptions.delegate = self
        options = basicOptions
    }
    
    public func selectionAction(forFilterAt index: Int) -> SearchOptionAction {
        if let options = options as? LocationAdvanceSearchOptions {
            let updateHandler = { [weak self] in
                guard let `self` = self else { return }
                self.updatingDelegate?.searchDataSource(self, didUpdateComponent: .filter(index: index))
            }
            
            if let controller = options.pickerController(forFilterAt: index, updateHandler: updateHandler) {
                return .options(controller: controller)
            }
        } else if let options = options as? LocationBasicSearchOptions {
            performSearchOnLocation(options.locations[index])
        }
        
        return .none
    }
    
    public func textChanged(forFilterAt index: Int, text: String?, didEndEditing ended: Bool) {
        if let options = options as? LocationAdvanceSearchOptions {
            options.populate(with: [index: text ?? ""], reset: false)
            updatingDelegate?.searchDataSource(self, didUpdateComponent: .filterErrorMessage(index: index))
        }
    }
    
    public func prefill(withSearchable searchable: Searchable) -> Bool {
        let type = searchable.type
        
        if type == nil {
            text = searchable.text
            
            basicOptions.reset()
            advanceOptions.populate(with: nil, reset: true)
            
            options = basicOptions
            return true
        } else if type == LocationSearchDataSource.searchableType {
            let type = searchable.type
            if type == LocationSearchDataSource.searchableType {
                basicOptions.reset()
                advanceOptions.populate(with: nil, reset: true)
                
                if let lastOptions = searchable.options {
                    text = nil
                    advanceOptions.populate(with: lastOptions, reset: true)
                    options = advanceOptions
                } else {
                    text = searchable.text
                    options = basicOptions
                }
            }
            
            return true
        }

        return false
    }
    
    // MARK: - Private
    
    @objc private func didTapHelpButton() {
        // FIXME: - When the appropriate time comes please change it
        let helpViewController = UIViewController()
        helpViewController.title = "Location Search Help"
        helpViewController.view.backgroundColor = .white
        (self.updatingDelegate as? UIViewController)?.show(helpViewController, sender: nil)
    }
    
    @objc private func didTapSimpleSearchButton() {
        options = basicOptions
    }
    
    @objc private func didTapAdvanceButton() {
        options = advanceOptions
    }
    
    @objc private func didTapSearchButton() {
        let search = Searchable(text: advanceOptions.textRepresentation(),
                                options: advanceOptions.state(),
                                type: LocationSearchDataSource.searchableType)
        updatingDelegate?.searchDataSource(self, didFinishWith: search, andResultViewModel: nil)

    }
    
    @objc private func didTapMapButton() {
        // TODO: Present map
    }
    
    private func attemptSearch(delay: Bool = true) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(lookupLocations), object: nil)
        self.perform(#selector(lookupLocations), with: nil, afterDelay: delay ? searchStrategy.configuration.throttle : 0.0)
    }
    
    private var lastSearchText: String?
    
    @objc private func lookupLocations() {
        guard let text = text, text.characters.count > searchStrategy.configuration.minimumCharacters, text != lastSearchText else { return }
        
        if let promise = self.searchStrategy.locationSearchPromise(text: text) {
            self.lastSearchText = text
            self.errorMessage = nil
            
            promise.then { [weak self] locations -> () in
                guard let `self` = self, self.lastSearchText == text else { return }
                
                if locations.isEmpty {
                    self.errorMessage = "No addresses found for '\(text)'."
                } else {
                    self.basicOptions.locations = locations
                    self.updatingDelegate?.searchDataSource(self, didUpdateComponent: .filter(index: nil))
                }
            }.catch { [weak self] in
                guard let `self` = self, self.lastSearchText == text else { return }
                    
                let error = $0 as? MappedError
                self.errorMessage = error?.localizedDescription
            }
        }
    }

    // MARK: - Search text handling
    
    private func searchTextDidChange(_ text: String?, _ endEditing: Bool) {
        self.text = text
        attemptSearch(delay: !endEditing)
    }

    // MARK: - Handle address
    
    private func performSearchOnLocation(_ location: Pickable) {
        let searchable = Searchable(text: text, options: nil, type: LocationSearchDataSource.searchableType)
        updatingDelegate?.searchDataSource(self, didFinishWith: searchable, andResultViewModel: nil)
        
        let mapViewController = UIViewController()
        mapViewController.title = "Location Search"
        mapViewController.view.backgroundColor = .white
        (updatingDelegate as? UIViewController)?.show(mapViewController, sender: nil)
    }
    
    public func locationBasicSearchOptions(_ options: LocationBasicSearchOptions, didEditLocation location: Pickable) {
        self.options = advanceOptions
    }
}


