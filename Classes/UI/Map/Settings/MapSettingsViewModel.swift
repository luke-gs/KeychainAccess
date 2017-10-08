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
    
    /// Whether the mode at the index supports traffic
    public func isTrafficSupported(at index: Int) -> Bool {
        guard index < availableModes.count else { return false }
        
        let indexMode = availableModes[index]
        return isTrafficSupported(for: indexMode)
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
    
    /// Updates the traffic setting to match the switch
    public func setTrafficEnabled(_ enabled: Bool) {
        showTraffic = enabled
    }
}

public protocol MapSettingsViewModelDelegate: class {
    /// Called when the mode or traffic setting changed
    func modeDidChange(to mode: MKMapType, showsTraffic: Bool)
}
