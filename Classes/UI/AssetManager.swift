//
//  AssetManager.swift
//  MPOLKit
//
//  Created by Rod Brown on 21/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class AssetManager {
    
    public static let shared: AssetManager = AssetManager()
    
    private var localImageMap: [MPOLImage: (name: String, bundle: Bundle)] = [:]
    
    private init() {
    }
    
    
    // MARK: - Image assets
    
    public func registerImage(named name: String?, in bundle: Bundle?, for image: MPOLImage) {
        if let name = name, let bundle = bundle {
            localImageMap[image] = (name, bundle)
        } else {
            localImageMap.removeValue(forKey: image)
        }
    }
    
    public func image(for mpolImage: MPOLImage, compatibleWith traitCollection: UITraitCollection? = nil) -> UIImage? {
        
        if let fileLocation = localImageMap[mpolImage],
            let asset = UIImage(named: fileLocation.name, in: fileLocation.bundle, compatibleWith: traitCollection) {
            return asset
        }
        
        return UIImage(named: mpolImage.rawValue, in: .mpolKit, compatibleWith: traitCollection)
    }
    
}

public struct MPOLImage: RawRepresentable {
    
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    
    // Tab Bar Icons
    public static let tabBarActionList = MPOLImage("iconTabBarActionList")
    public static let tabBarEvents     = MPOLImage("iconTabBarEvents")
    public static let tabBarTasks      = MPOLImage("iconTabBarTasks")
    public static let tabBarResources  = MPOLImage("iconTabBarResources")
    public static let tabBarComms      = MPOLImage("iconTabBarComms")
    
    // Nav Bar Icons
    public static let back           = MPOLImage("iconNavBarBack")
    public static let filter         = MPOLImage("iconNavBarFilter")
    public static let pin            = MPOLImage("iconNavBarPin")
    public static let settings       = MPOLImage("iconNavBarSettings")
    
    // System
    public static let search         = MPOLImage("iconTabSystemSearch")
    public static let add            = MPOLImage("iconSystemAdd")
    public static let close          = MPOLImage("iconSystemClose")
    public static let checkmark      = MPOLImage("iconSystemCheckmark")
    public static let edit           = MPOLImage("iconSystemEdit")
    public static let info           = MPOLImage("iconSystemInfo")
    public static let time           = MPOLImage("iconSystemTime")
    public static let date           = MPOLImage("iconSystemDate")
    public static let location       = MPOLImage("iconSystemLocation")
    public static let list           = MPOLImage("iconSystemList")
    public static let thumbnail      = MPOLImage("iconSystemThumbnail")
    public static let dropDown       = MPOLImage("iconSystemDropdown")
    public static let disclosure     = MPOLImage("iconSystemDisclosure")
    
    // General
    public static let alert          = MPOLImage("iconGeneralAlert")
    public static let association    = MPOLImage("iconGeneralAssociation")
    public static let event          = MPOLImage("iconGeneralEvent")
    public static let document       = MPOLImage("iconGeneralDocument")
    public static let direction      = MPOLImage("iconGeneralDirection")
    public static let service        = MPOLImage("iconGeneralService")
    public static let attachment     = MPOLImage("iconGeneralAttachment")
    public static let finalise       = MPOLImage("iconGeneralFinalise")
    public static let tactical       = MPOLImage("iconGeneralTactical")
    public static let journey        = MPOLImage("iconGeneralJourney")
    public static let mass           = MPOLImage("iconGeneralMass")
    
    // Entity
    public static let entityOfficer  = MPOLImage("iconEntityOfficer")
    public static let entityPerson   = MPOLImage("iconEntityPerson")
    public static let entityBuilding = MPOLImage("iconEntityBuilding")
    public static let entityCar      = MPOLImage("iconEntityVehicleCar")
    public static let entityTruck    = MPOLImage("iconEntityVehicleTruck")
    
    // Comms
    public static let audioCall      = MPOLImage("iconCommsCall")
    public static let videoCall      = MPOLImage("iconCommsVideo")
    
    // Forms
    public static let checkbox             = MPOLImage("iconCheckbox")
    public static let checkboxSelected     = MPOLImage("iconCheckboxSelected")
    public static let radioButton          = MPOLImage("iconRadio")
    public static let radioButtonSelected  = MPOLImage("iconRadioSelected")
    public static let formCheckmark        = MPOLImage("iconFormCheckmark")
    
    // Source bar
    public static let sourceBarDownload    = MPOLImage("SourceBarDownload")
    public static let sourceBarNone        = MPOLImage("SourceBarNone")
    
}


// MARK: - Hashable

extension MPOLImage: Hashable {
    
    public var hashValue: Int {
        return self.rawValue.hashValue
    }
    
}

public func == (lhs: MPOLImage, rhs: MPOLImage) -> Bool {
    return lhs.rawValue == rhs.rawValue
}



