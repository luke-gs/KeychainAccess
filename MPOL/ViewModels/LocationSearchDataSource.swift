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


extension Address: Pickable {
    public var title: String? { return "\(arc4random_uniform(200) + 1)/28 Wellington St." }
    public var subtitle: String? { return "\(arc4random_uniform(200) + 1) m" }
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
            return .search(configure: { [weak self] (searchView: SearchFieldCollectionViewCell) in
                guard let `self` = self else { return }
                
                let textField = searchView.textField
                
                textField.text                   = self.text
                textField.keyboardType           = .asciiCapable
                textField.autocapitalizationType = .words
                textField.autocorrectionType     = .no
                textField.returnKeyType          = .go
                textField.attributedPlaceholder  = self.searchPlaceholder
                textField.delegate               = self
                
                if textField.allTargets.contains(self) == false {
                    textField.addTarget(self, action: #selector(self.textFieldTextDidChange(_:)), for: .editingChanged)
                }
                
                searchView.additionalButtons     = self.additionalSearchButtons
            }, message: self.errorMessage)
        } else {
            return .button(configure: { [weak self] (searchView: SearchFieldAdvanceCell) in
                guard let `self` = self else { return }
                
                let actionButton = searchView.actionButton
                actionButton.setTitle(NSLocalizedString("GO BACK TO SIMPLE SEARCH", comment: "Location Search - Back to simple search"), for: .normal)
                
                if actionButton.actions(forTarget: self, forControlEvent: .touchUpInside) == nil {
                    actionButton.addTarget(self, action: #selector(self.didTapSimpleSearchButton), for: .touchUpInside)
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
    
    func textChanged(forFilterAt index: Int, text: String?) {
        if let options = options as? LocationAdvanceSearchOptions {
            guard let item = LocationAdvanceItem(rawValue: index) else { return }
            
            switch item {
            case .unit: options.unit = text
                updatingDelegate?.searchDataSource(self, didUpdateComponent: .searchStyle)
            case .streetName: options.streetName = text
            case .streetNumberStart: options.streetNumberStart = text
            case .streetNumberEnd: options.streetNumberEnd = text
            case .postcode: options.postcode = text
            case .suburb: options.suburb = text
            default: break
            }
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
        var locations = [Address]()
        
        let max = Int(arc4random_uniform(10))
        for _ in 0..<max {
            locations.append(Address())
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
            self.basicOptions.locations = locations
            self.updatingDelegate?.searchDataSource(self, didUpdateComponent: .filter(index: nil))
        })
    }

    // MARK: - Text field delegate
    
    @objc private func textFieldTextDidChange(_ textField: UITextField) {
        text = textField.text
        attemptSearch()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        attemptSearch(delay: false)
        return false
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

