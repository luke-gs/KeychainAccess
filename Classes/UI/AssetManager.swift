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
    public struct ImageKey: RawRepresentable, Hashable, Codable {
        
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
        public static let tabBarEvents     = ImageKey("iconTabBarEvents")
        public static let tabBarTasks      = ImageKey("iconTabBarTasks")
        public static let tabBarComms      = ImageKey("iconTabBarComms")
        public static let tabBarActivity   = ImageKey("iconTabBarActivityLog")
        public static let tabBarSearch     = ImageKey("iconTabBarSearch")
        
        public static let tabBarEventsSelected     = ImageKey("iconTabBarEventsSelected")
        public static let tabBarTasksSelected      = ImageKey("iconTabBarTasksSelected")
        public static let tabBarCommsSelected      = ImageKey("iconTabBarCommsSelected")
        public static let tabBarActivitySelected   = ImageKey("iconTabBarActivityLogSelected")
        public static let tabBarSearchSelected     = ImageKey("iconTabBarSearchSelected")

        // Nav Bar Icons
        public static let back           = ImageKey("iconNavBarBack")
        public static let filter         = ImageKey("iconNavBarFilter")
        public static let filterFilled   = ImageKey("iconNavBarFilterSelected")
        public static let settings       = ImageKey("iconNavBarSettings")
        
        // System
        public static let add            = ImageKey("iconSystemAdd")
        public static let close          = ImageKey("iconSystemClose")
        public static let edit           = ImageKey("iconSystemEdit")
        public static let editCell       = ImageKey("iconSystemEditCell")
        public static let info           = ImageKey("iconSystemInfo")
        public static let infoFilled     = ImageKey("iconSystemInfoFilled")
        public static let time           = ImageKey("iconSystemTime")
        public static let date           = ImageKey("iconSystemDate")
        public static let location       = ImageKey("iconSystemLocation")
        public static let thumbnail      = ImageKey("iconSystemThumbnail")
        public static let dropDown       = ImageKey("iconSystemDropdown")
        public static let disclosure     = ImageKey("iconSystemDisclosure")
        public static let overflow       = ImageKey("iconSystemOverflow")
        public static let advancedSearch = ImageKey("iconSystemAdvancedSearch")
        public static let login          = ImageKey("iconSystemLogin")
        public static let nightMode      = ImageKey("iconSystemNightMode")
        public static let keyboard       = ImageKey("iconSystemKeyboard")

        public static let faceId  = ImageKey("iconBiometricFaceId")
        public static let touchId = ImageKey("iconBiometricTouchId")

        public static let navBarThumbnail         = ImageKey("iconNavBarThumbnail")
        public static let navBarThumbnailSelected = ImageKey("iconNavBarThumbnailSelected")

        // Media
        public static let play           = ImageKey("iconMediaPlay")
        public static let audioWave      = ImageKey("audioWave")
        public static let iconPlay       = ImageKey("iconPlay")
        public static let iconPause      = ImageKey("iconPause")
        public static let download       = ImageKey("download")

        // General
        public static let alert          = ImageKey("iconGeneralAlert")
        public static let alertFilled    = ImageKey("iconGeneralAlertFilled")
        public static let association    = ImageKey("iconGeneralAssociation")
        public static let event          = ImageKey("iconGeneralEvent")
        public static let document       = ImageKey("iconGeneralDocument")
        public static let documentFilled = ImageKey("iconGeneralDocumentFilled")
        public static let direction      = ImageKey("iconGeneralDirection")
        public static let service        = ImageKey("iconGeneralService")
        public static let attachment     = ImageKey("iconGeneralAttachment")
        public static let finalise       = ImageKey("iconGeneralFinalise")
        public static let tactical       = ImageKey("iconGeneralTactical")
        public static let journey        = ImageKey("iconGeneralJourney")
        public static let list           = ImageKey("iconGeneralList")
        public static let mass           = ImageKey("iconGeneralMass")
        public static let map            = ImageKey("iconGeneralMap")
        public static let folder         = ImageKey("iconFormFolder")
        public static let refresh        = ImageKey("iconGeneralRefreshMagnify")
        public static let email          = ImageKey("iconFormEmail")
        public static let duress         = ImageKey("iconDuress")
        public static let route          = ImageKey("iconGeneralRoute")
        public static let streetView     = ImageKey("iconGeneralStreetView")
        public static let clearText      = ImageKey("iconClearText")

        public static let generalLocation = ImageKey("iconGeneralLocation")
        public static let otherPatrolArea = ImageKey("iconOtherPatrolArea")

        // Map
        public static let pinLocation    = ImageKey("pinLocation")
        public static let pinDefault     = ImageKey("pinDefault")
        public static let pinCluster     = ImageKey("pinCluster")
        
        // Entity
        public static let entityOfficer  = ImageKey("iconEntityOfficer")
        public static let entityPerson   = ImageKey("iconEntityPerson")
        public static let entityBuilding = ImageKey("iconEntityBuilding")
        public static let entityCar      = ImageKey("iconEntityAutomotiveCar")
        public static let entityTruck    = ImageKey("iconEntityVehicleTruck")
        public static let entityBoat     = ImageKey("iconEntityAutomotiveWater")

        public static let entityPersonMedium = ImageKey("iconEntityPerson32")

        public static let entityCarSmall = ImageKey("iconEntityAutomotiveCarSmall")
        public static let entityCarMedium = ImageKey("iconEntityAutomotiveCarMedium")
        public static let entityCarLarge = ImageKey("iconEntityAutomotiveCarLarge")

        public static let entityMotorbikeSmall = ImageKey("iconEntityAutomotiveMotorbikeSmall")
        public static let entityMotorbikeMedium = ImageKey("iconEntityAutomotiveMotorbikeMedium")
        public static let entityMotorbikeLarge = ImageKey("iconEntityAutomotiveMotorbikeLarge")

        public static let entityTruckSmall = ImageKey("iconEntityVehicleTruckSmall")
        public static let entityTruckMedium = ImageKey("iconÍEntityVehicleTruckMedium")
        public static let entityTruckLarge = ImageKey("iconEntityVehicleTruckLarge")

        public static let entityTrailerSmall = ImageKey("iconEntityAutomotiveTrailerSmall")
        public static let entityTrailerMedium = ImageKey("iconEntityAutomotiveTrailerMedium")
        public static let entityTrailerLarge = ImageKey("iconEntityAutomotiveTrailerLarge")

        public static let entityTrailer2Small = ImageKey("iconEntityAutomotiveTrailer2Small")
        public static let entityTrailer2Medium = ImageKey("iconEntityAutomotiveTrailer2Medium")
        public static let entityTrailer2Large = ImageKey("iconEntityAutomotiveTrailer2Large")

        @available(iOS, deprecated, message: "EntityThumbnail now uses themed coloured backgrounds")
        public static let entityPlaceholder = ImageKey("EntityThumbnailBackground")

        public static let iconEntityVehicleMotorcycle = ImageKey("iconEntityVehicleMotorcycle")

        public static let entityMotorcycleSmall = ImageKey("iconEntityVehicleMotorcycleSmall")
        public static let entityMotorcycleMedium = ImageKey("iconEntityVehicleMotorcycleMedium")
        public static let entityMotorcycleLarge = ImageKey("iconEntityVehicleMotorcycleLarge")

        public static let entityVanSmall = ImageKey("iconEntityVehicleVanSmall")
        public static let entityVanMedium = ImageKey("iconEntityVehicleVanMedium")
        public static let entityVanLarge = ImageKey("iconEntityVehicleVanLarge")

        public static let entityBoatSmall = ImageKey("iconEntityAutomotiveWaterSmall")
        public static let entityBoatMedium = ImageKey("iconEntityAutomotiveWaterMedium")
        public static let entityBoatLarge = ImageKey("iconEntityAutomotiveWaterLarge")

        // Resource
        public static let resourceGeneral       = ImageKey("iconResourceGeneral")
        public static let resourceDevice        = ImageKey("iconResourceDevice")
        public static let resourceCar           = ImageKey("iconResourceCar")
        public static let resourceWater         = ImageKey("iconResourceWater")
        public static let resourceBicycle       = ImageKey("iconResourceBicycle")
        public static let resourceHelicopter    = ImageKey("iconResourceHelicopter")
        public static let resourceBeat          = ImageKey("iconResourceBeat")
        public static let resourceDog           = ImageKey("iconResourceDog") // woof woof
        public static let resourceSegway        = ImageKey("iconResourceSegway")

        public static let resourceCarLarge      = ImageKey("icon32ResourceCar")

        // Sketch
        public static let penStub = ImageKey("penStub")
        public static let penNib = ImageKey("penNib")
        public static let rubber = ImageKey("rubber")
        
        // Comms
        public static let commsDevice    = ImageKey("iconCommsDevice")
        public static let commsEmail     = ImageKey("iconCommsEmail")
        public static let post           = ImageKey("iconCommsPost")
        public static let audioCall      = ImageKey("iconCommsCall")
        public static let videoCall      = ImageKey("iconCommsVideo")
        public static let message        = ImageKey("iconCommsMessage")
        public static let gallery        = ImageKey("iconCommsGallery")

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
        public static let mapCurrentLocation         = ImageKey("iconCurrentLocation")

        // Loading states
        public static let iconLoadingFailed          = ImageKey("iconLoadingFailed")

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

        // Events
        public static let iconFolder          = ImageKey("iconFolder")
        public static let iconPencil          = ImageKey("iconPencil")
        public static let iconDocument        = ImageKey("iconDocument")
        public static let iconRelationships   = ImageKey("iconGeneralRelationships")
        public static let iconHeaderFinalise  = ImageKey("icon40StatusFinalise")
        public static let iconHeaderEdit      = ImageKey("icon40SystemEdit")
        public static let eventDateTime       = ImageKey("iconSystemDateAndTime")
        public static let eventLocation       = ImageKey("iconEntityLocation")

        // Dialog images
        public static let dialogAlert = ImageKey("dialogAlert")
    }
}

public func == (lhs: AssetManager.ImageKey, rhs: AssetManager.ImageKey) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

