//
//  AssetManager.swift
//  MPOLKit
//
//  Created by Rod Brown on 21/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// The Asset Manager for MPOL applications.
///
/// The asset manager allows you to access the assets within different bundles
/// within MPOLKit. You can also register overrides for MPOL standard assets,
/// or add additional items to be managed.
///
/// By default, if you ask for MPOL standard items, MPOL will first check if any
/// custom items have been registered, and use them if it can find it. If no
/// custom item has been registered, or no asset has been found, it will use MPOL
/// default assets.
public final class AssetManager {
    
    /// The shared asset manager singleton.
    public static let shared: AssetManager = AssetManager()
    
    private var localImageMap: [MPOLImage: (name: String, bundle: Bundle)] = [:]
    
    private init() {
    }
    
    
    // MARK: - Image assets
    
    
    /// Registers an image by name from within a bundle in the application loading.
    /// This avoids loading the image into the cache by trying to retrieve it and set
    /// it directly.
    ///
    /// If you pass `nil` for either the name or bundle, any previous registration
    /// will be removed.
    ///
    /// - Parameters:
    ///   - name:   The asset catalogue or file name within the specified bundle.
    ///   - bundle: The bundle containing the asset catalogue or file.
    ///   - image:  The MPOLImage to register for.
    public func registerImage(named name: String?, in bundle: Bundle?, for image: MPOLImage) {
        if let name = name, let bundle = bundle {
            localImageMap[image] = (name, bundle)
        } else {
            localImageMap.removeValue(forKey: image)
        }
    }
    
    
    /// Fetches an image either registered, or from within MPOLKit bundle.
    ///
    /// - Parameters:
    ///   - mpolImage:       The MPOL image to fetch.
    ///   - traitCollection: The trait collection to fetch the asset for. The default is `nil`.
    /// - Returns: A `UIImage` instance if one could be found matching the criteria, or `nil`.
    public func image(for mpolImage: MPOLImage, compatibleWith traitCollection: UITraitCollection? = nil) -> UIImage? {
        
        if let fileLocation = localImageMap[mpolImage],
            let asset = UIImage(named: fileLocation.name, in: fileLocation.bundle, compatibleWith: traitCollection) {
            return asset
        }
        
        return UIImage(named: mpolImage.rawValue, in: .mpolKit, compatibleWith: traitCollection)
    }
    
}




/// A struct wrapping the concept of an MPOLImage.
///
/// You can define your own MPOLImages to register by using static constants and
/// initializing with custom raw values. Be sure you don't clash with any of the
/// system MPOL assets in your naming.
///
/// Below are a set of standard MPOL Image types.
///
/// Internal note: We use the actual asset names within MPOLKit's asset catalogues
/// as the raw value to avoid having to create a constant map within this file.
/// This also lets us avoid the issue where someone could delete the standard item.
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



