//
//  MapSettingsViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 5/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit

open class MapSettingsViewModel {
    
    public init() {}
    
    public weak var delegate: MapSettingsViewModelDelegate?
    
    /// Whether to show traffic on the map
    private var showTraffic: Bool = false {
        didSet {
            guard showTraffic != oldValue else { return }
            delegate?.modeDidChange(to: mode, showsTraffic: showTraffic)
        }
    }
    
    /// The currently selected map mode
    public private(set) var mode: MKMapType = .standard {
        didSet {
            guard mode != oldValue else { return }
            delegate?.modeDidChange(to: mode, showsTraffic: showTraffic)
        }
    }
    
    /// Available map modes to select from
    private let availableModes: [MKMapType] = {
        return [.standard, .satellite, .hybrid]
    }()
    
    /// Title for the mode at specified index
    public func segments() -> [String] {
        let titles: [String?] = availableModes.map { mode in
            switch mode {
            case .standard: return "Standard"
            case .satellite: return "Satellite"
            case .hybrid: return "Hybrid"
            default: return nil
            }
        }
            
        return titles.removeNils()
    }
    
    /// Whether to show traffic as enabled
    public func isTrafficEnabled() -> Bool {
        return isTrafficSupported(for: mode) && showTraffic
    }
    
    /// Whether the specified mode supports traffic
    private func isTrafficSupported(for mode: MKMapType) -> Bool {
        switch mode {
        case .standard, .hybrid:
            return true
        default:
            return false
        }
    }
    
    /// The index of the selected mode
    public func selectedIndex() -> Int {
        if let index = availableModes.index(of: mode) {
            return index
        } else {
            return 0
        }
    }
    
    /// Updates the mode to match the selected segment
    public func setMode(at index: Int) {
        guard index < availableModes.count else { return }
        mode = availableModes[index]
    }
    
    // MARK: - Layers
    
    public enum Layers {
        case traffic
        
        var title: String {
            return NSLocalizedString("Traffic", comment: "Traffic Layer")
        }
    }
    
    open var layers: [Layers] {
        return [.traffic]
    }
    
    /// Called when a layer value is changed
    open func changedLayer(at index: Int, to enabled: Bool) {
        guard let layer = layers[ifExists: index] else { return }
        
        switch layer {
        case .traffic:
            setTrafficEnabled(enabled)
        }
    }
    
    /// Whether the layer toggle is in the on state at the index
    open func isLayerOn(at index: Int) -> Bool {
        guard let layer = layers[ifExists: index] else { return false }

        switch layer {
        case .traffic:
            return isTrafficEnabled()
        }
    }
    
    /// Whether the layer toggle is enabled (toggleable) at the index
    open func isLayerEnabled(at index: Int) -> Bool {
        guard let layer = layers[ifExists: index] else { return false }
        
        switch layer {
        case .traffic:
            return isTrafficSupported(for: mode)
        }
    }
    
    /// Updates the traffic setting to match the switch
    public func setTrafficEnabled(_ enabled: Bool) {
        // Toggle to off first for stupid Apple bug
        showTraffic = false
        showTraffic = enabled
    }
    
    // MARK: - Strings
    
    /// Title for navigation bar
    public func navTitle() -> String {
        return NSLocalizedString("Map Settings", comment: "")
    }
    
    /// The view controller to present when pressing settings button
    public func settingsViewController() -> UIViewController {
        return MapSettingsViewController(viewModel: self)
    }
    
    /// Text for the type label
    public func typeLabelText() -> String {
        return NSLocalizedString("Type", comment: "Map Type")
    }
    
    /// Text for the layers label
    public func layersLabelText() -> String {
        return NSLocalizedString("Additional Layers", comment: "Map Layers")
    }
    
    /// Text for the layers description label
    public func layersDescriptionLabelText() -> String {
        return NSLocalizedString("Show these layers on the map", comment: "Map Layers Description")
    }
    
}

public protocol MapSettingsViewModelDelegate: class {
    /// Called when the mode or traffic setting changed
    func modeDidChange(to mode: MKMapType, showsTraffic: Bool)
}
