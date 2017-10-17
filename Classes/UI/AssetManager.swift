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
    
    private var localImageMap: [ImageKey: (name: String, bundle: Bundle)] = [:]
    
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
    ///   - key:    The ImageKey to register for.
    public func registerImage(named name: String?, in bundle: Bundle?, forKey key: ImageKey) {
        if let name = name, let bundle = bundle {
            localImageMap[key] = (name, bundle)
        } else {
            localImageMap.removeValue(forKey: key)
        }
    }
    
    
    /// Fetches an image either registered, or from within MPOLKit bundle.
    ///
    /// - Parameters:
    ///   - key:             The MPOL image key to fetch.
    ///   - traitCollection: The trait collection to fetch the asset for. The default is `nil`.
    /// - Returns: A `UIImage` instance if one could be found matching the criteria, or `nil`.
    public func image(forKey key: ImageKey, compatibleWith traitCollection: UITraitCollection? = nil) -> UIImage? {
        if let fileLocation = localImageMap[key],
            let asset = UIImage(named: fileLocation.name, in: fileLocation.bundle, compatibleWith: traitCollection) {
            return asset
        }
        
        return UIImage(named: key.rawValue, in: .mpolKit, compatibleWith: traitCollection)
    }
    
}




extension AssetManager {
    
    /// A struct wrapping the concept of an ImageKey.
    ///
    /// You can define your own ImageKeys to register by using static constants and
    /// initializing with custom raw values. Be sure you don't clash with any of the
    /// system MPOL assets in your naming.
    ///
    /// Below are a set of standard MPOL Image types.
    ///
    /// Internal note: We currently use the actual asset names within MPOLKit's asset
    /// catalogues as the raw value to avoid having to create a constant map within this
    /// file. This also lets us avoid the issue where someone could delete the standard
    /// item. This can change at a later time.
    public struct ImageKey: RawRepresentable, Hashable {
        
        // Book-keeping
        
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public var hashValue: Int {
            return rawValue.hashValue
        }
        
        
        // Tab Bar Icons
        public static let tabBarActionList = ImageKey("iconTabBarActionList")
        public static let tabBarEvents     = ImageKey("iconTabBarEvents")
        public static let tabBarTasks      = ImageKey("iconTabBarTasks")
        public static let tabBarResources  = ImageKey("iconTabBarResources")
        public static let tabBarComms      = ImageKey("iconTabBarComms")
        public static let tabBarActivity   = ImageKey("iconTabBarActivityLog")

        // Nav Bar Icons
        public static let back           = ImageKey("iconNavBarBack")
        public static let filter         = ImageKey("iconNavBarFilter")
        public static let filterFilled   = ImageKey("iconNavBarFilterFilled")
        public static let pin            = ImageKey("iconNavBarPin")
        public static let settings       = ImageKey("iconNavBarSettings")
        
        // System
        public static let add            = ImageKey("iconSystemAdd")
        public static let close          = ImageKey("iconSystemClose")
        public static let edit           = ImageKey("iconSystemEdit")
        public static let info           = ImageKey("iconSystemInfo")
        public static let time           = ImageKey("iconSystemTime")
        public static let date           = ImageKey("iconSystemDate")
        public static let location       = ImageKey("iconSystemLocation")
        public static let list           = ImageKey("iconSystemList")
        public static let thumbnail      = ImageKey("iconSystemThumbnail")
        public static let dropDown       = ImageKey("iconSystemDropdown")
        public static let disclosure     = ImageKey("iconSystemDisclosure")
        public static let advancedSearch = ImageKey("iconSystemAdvancedSearch")
        
        // General
        public static let alert          = ImageKey("iconGeneralAlert")
        public static let association    = ImageKey("iconGeneralAssociation")
        public static let event          = ImageKey("iconGeneralEvent")
        public static let document       = ImageKey("iconGeneralDocument")
        public static let direction      = ImageKey("iconGeneralDirection")
        public static let service        = ImageKey("iconGeneralService")
        public static let attachment     = ImageKey("iconGeneralAttachment")
        public static let finalise       = ImageKey("iconGeneralFinalise")
        public static let tactical       = ImageKey("iconGeneralTactical")
        public static let journey        = ImageKey("iconGeneralJourney")
        public static let mass           = ImageKey("iconGeneralMass")
        public static let folder         = ImageKey("iconFormFolder")
        public static let refresh        = ImageKey("iconGeneralRefreshMagnify")
        public static let email          = ImageKey("iconFormEmail")

        public static let generalLocation = ImageKey("iconGeneralLocation")
        
        // Entity
        public static let entityOfficer  = ImageKey("iconEntityOfficer")
        public static let entityPerson   = ImageKey("iconEntityPerson")
        public static let entityBuilding = ImageKey("iconEntityBuilding")
        public static let entityCar      = ImageKey("iconEntityVehicleCar")
        public static let entityTruck    = ImageKey("iconEntityVehicleTruck")
        
        // Resource
        public static let resourceCar       = ImageKey("iconResourceCar")
        public static let resourceWater     = ImageKey("iconResourceWater")
        public static let resourceBicycle   = ImageKey("iconResourceBicycle")
        public static let resourceAir       = ImageKey("iconResourceAir")
        public static let resourceSegway    = ImageKey("iconResourceSegway")
        public static let resourceDog       = ImageKey("iconResourceDog") // woof woof
        
        // Comms
        public static let audioCall      = ImageKey("iconCommsCall")
        public static let videoCall      = ImageKey("iconCommsVideo")
        
        // Forms
        public static let checkbox             = ImageKey("iconFormCheckbox")
        public static let checkboxSelected     = ImageKey("iconFormCheckboxSelected")
        public static let radioButton          = ImageKey("iconFormRadio")
        public static let radioButtonSelected  = ImageKey("iconFormRadioSelected")
        public static let checkmark            = ImageKey("iconFormCheckmark")
        
        // Source bar
        public static let sourceBarDownload    = ImageKey("SourceBarDownload")
        public static let sourceBarNone        = ImageKey("SourceBarNone")
        
        // Map
        public static let mapUserLocation            = ImageKey("iconUserLocation")
        public static let mapUserTracking            = ImageKey("iconUserTracking")
        public static let mapUserTrackingWithHeading = ImageKey("iconUserTrackingWithHeading")

        // CAD status
        public static let iconStatusAtIncident   = ImageKey("iconStatusAtIncident")
        public static let iconStatusCourt        = ImageKey("iconStatusCourt")
        public static let iconStatusFinalise     = ImageKey("iconStatusFinalise")
        public static let iconStatusInquiries    = ImageKey("iconStatusInquiries")
        public static let iconStatusMealBreak    = ImageKey("iconStatusMealBreak")
        public static let iconStatusOnAir        = ImageKey("iconStatusOnAir")
        public static let iconStatusOnCall       = ImageKey("iconStatusOnCall")
        public static let iconStatusProceeding   = ImageKey("iconStatusProceeding")
        public static let iconStatusStation      = ImageKey("iconStatusStation")
        public static let iconStatusTrafficStop  = ImageKey("iconStatusTrafficStop")
        public static let iconStatusUnavailable  = ImageKey("iconStatusUnavailable")

    }
}

public func == (lhs: AssetManager.ImageKey, rhs: AssetManager.ImageKey) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

