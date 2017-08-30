//
//  LocationSearchDataSource.swift
//  MPOL
//
//  Created by KGWH78 on 21/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit
import PromiseKit
import Unbox


extension LookupAddress: Pickable {
    public var title: String? { return fullAddress }
    public var subtitle: String? { return "\(arc4random_uniform(30)) m" }
}

class LocationSearchDataSource: NSObject, SearchDataSource, UITextFieldDelegate, LocationBasicSearchOptionsDelegate {
    
    static let searchableType = "Location"
    
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
    
    private var errorMessage: String?

    var searchStyle: SearchFieldStyle {
        if options is LocationBasicSearchOptions {
            return .search(configure: { [weak self] (textField) in
                guard let `self` = self else { return nil }
                
                textField.text                   = self.text
                textField.keyboardType           = .asciiCapable
                textField.autocapitalizationType = .words
                textField.autocorrectionType     = .no
                textField.returnKeyType          = .go
                textField.attributedPlaceholder  = self.searchPlaceholder
                
                return self.additionalSearchButtons
            }, textHandler: self.searchTextDidChange, errorMessage: self.errorMessage)
        } else {
            return .button(configure: { [weak self] (button) in
                guard let `self` = self else { return }
                
                button.setTitle(NSLocalizedString("GO BACK TO SIMPLE SEARCH", comment: "Location Search - Back to simple search"), for: .normal)
                
                if button.actions(forTarget: self, forControlEvent: .touchUpInside) == nil {
                    button.addTarget(self, action: #selector(self.didTapSimpleSearchButton), for: .touchUpInside)
                }
            })
        }
    }
    
    private lazy var searchButton: UIBarButtonItem? = UIBarButtonItem(title: NSLocalizedString("Search", comment: ""), style: .done, target: self, action: #selector(didTapSearchButton))
    private lazy var advanceButton: UIBarButtonItem? = UIBarButtonItem(title: NSLocalizedString("Advance Search", comment: ""), style: .done, target: self, action: #selector(didTapAdvanceButton))
    
    var navigationButton: UIBarButtonItem? {
        return options is LocationBasicSearchOptions ? advanceButton : searchButton
    }
    
    var options: SearchOptions? {
        didSet {
            updatingDelegate?.searchDataSource(self, didUpdateComponent: .all)
        }
    }

    private let basicOptions   = LocationBasicSearchOptions()
    private let advanceOptions = LocationAdvanceSearchOptions()

    weak var updatingDelegate: SearchDataSourceUpdating?
    
    var localizedDisplayName: String {
        return NSLocalizedString("Location", comment: "")
    }
    
    override init() {
        super.init()
        
        basicOptions.delegate = self
        options = basicOptions
    }
    
    func selectionAction(forFilterAt index: Int) -> SearchOptionAction {
        if let options = options as? LocationAdvanceSearchOptions {
            guard let item = LocationAdvanceItem(rawValue: index) else { return .none }
            
            // Handle advance options
            switch item {
            case .streetType:
                let types = StreetType.all
                let picker = pickerController(forFilterAt: index, items: types, selectedIndexes: types.indexes { $0 == options.streetType }, onSelect: { (_, selectedIndexes) in
                    guard let selectedTypeIndex = selectedIndexes.first else { return }
                    options.streetType = types[selectedTypeIndex]
                })
                return .options(controller: picker)
            case .state:
                let types = StateType.all
                let picker = pickerController(forFilterAt: index, items: types, selectedIndexes: types.indexes { $0 == options.state }, onSelect: { (_, selectedIndexes) in
                    guard let selectedTypeIndex = selectedIndexes.first else { return }
                    options.state = types[selectedTypeIndex]
                })
                return .options(controller: picker)
            default:
                return .none
            }
        } else if let options = options as? LocationBasicSearchOptions {
            // Handle basic options
            performSearchOnLocation(options.locations[index])
        }
        
        return .none
    }
    
    func textChanged(forFilterAt index: Int, text: String?, didEndEditing ended: Bool) {
        if let options = options as? LocationAdvanceSearchOptions {
            guard let item = LocationAdvanceItem(rawValue: index) else { return }
            
            switch item {
            case .unit: options.unit = text
            case .streetName: options.streetName = text
            case .streetNumberStart: options.streetNumberStart = text
            case .streetNumberEnd: options.streetNumberEnd = text
            case .postcode: options.postcode = text
            case .suburb: options.suburb = text
            default: break
            }
            
            updatingDelegate?.searchDataSource(self, didUpdateComponent: .filterErrorMessage(index: index))
        }
    }
    
    func prefill(withSearchable searchable: Searchable) -> Bool {
        let type = searchable.type
        
        if type == nil {
            text = searchable.text
            
            basicOptions.reset()
            advanceOptions.reset()
            
            options = basicOptions
            return true
        } else if type == LocationSearchDataSource.searchableType {
            let type = searchable.type
            if type == LocationSearchDataSource.searchableType {
                basicOptions.reset()
                advanceOptions.reset()
                
                if let lastOptions = searchable.options {
                    text = nil
                    advanceOptions.populate(with: lastOptions)
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
        let search = Searchable(text: advanceOptions.textRepresentation,
                                options: advanceOptions.state(),
                                type: LocationSearchDataSource.searchableType)
        updatingDelegate?.searchDataSource(self, didFinishWith: search, andResultViewModel: nil)

    }
    
    @objc private func didTapMapButton() {
        // TODO: Present map
    }
    
    private func attemptSearch(delay: Bool = true) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(magic), object: nil)
        self.perform(#selector(magic), with: nil, afterDelay: delay ? 0.4 : 0.0)
    }
    
    @objc private func magic() {
        var locations = [LookupAddress]()
        
        let max = Int(arc4random_uniform(10))
        for _ in 0..<max {
            let data: [String: Any] = [
                "id": UUID().uuidString, "fullAddress":
                "\(arc4random_uniform(200) + 1)/28 Wellington St, Collingwood, VIC 3066",
                "latitude" : -37.807913,
                "longitude": 144.986060,
                "isAlias": false
            ]
            locations.append(try! LookupAddress(unboxer: Unboxer(dictionary: data)))
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
            self.basicOptions.locations = locations
            self.updatingDelegate?.searchDataSource(self, didUpdateComponent: .filter(index: nil))
        })
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
    
    func locationBasicSearchOptions(_ options: LocationBasicSearchOptions, didEditLocation location: Pickable) {
        self.options = advanceOptions
    }
}

