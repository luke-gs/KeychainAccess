//
//  AssetManager+PatternKit.swift
//  PatternKit
//
//  Created by Trent Fitzgibbon on 4/9/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import CoreKit

extension AssetManager.ImageKey {

    // Login Logos
    public static let GSLogo                      = AssetManager.ImageKey("imageGridstoneLogo")
    public static let MotoLogo                    = AssetManager.ImageKey("imageMotorolaLogo")

    // Tab Bar Icons
    public static let tabBarEvents                = AssetManager.ImageKey("iconTabBarEvents")
    public static let tabBarTasks                 = AssetManager.ImageKey("iconTabBarTasks")
    public static let tabBarComms                 = AssetManager.ImageKey("iconTabBarComms")
    public static let tabBarActivity              = AssetManager.ImageKey("iconTabBarActivityLog")
    public static let tabBarSearch                = AssetManager.ImageKey("iconTabBarSearch")

    public static let tabBarEventsSelected        = AssetManager.ImageKey("iconTabBarEventsSelected")
    public static let tabBarTasksSelected         = AssetManager.ImageKey("iconTabBarTasksSelected")
    public static let tabBarCommsSelected         = AssetManager.ImageKey("iconTabBarCommsSelected")
    public static let tabBarActivitySelected      = AssetManager.ImageKey("iconTabBarActivityLogSelected")
    public static let tabBarSearchSelected        = AssetManager.ImageKey("iconTabBarSearchSelected")

    // Nav Bar Icons
    public static let back                        = AssetManager.ImageKey("iconNavBarBack")
    public static let filter                      = AssetManager.ImageKey("iconNavBarFilter")
    public static let filterFilled                = AssetManager.ImageKey("iconNavBarFilterSelected")
    public static let settings                    = AssetManager.ImageKey("iconNavBarSettings")

    // System
    public static let add                         = AssetManager.ImageKey("iconSystemAdd")
    public static let close                       = AssetManager.ImageKey("iconSystemClose")
    public static let edit                        = AssetManager.ImageKey("iconSystemEdit")
    public static let editCell                    = AssetManager.ImageKey("iconSystemEditCell")
    public static let info                        = AssetManager.ImageKey("iconSystemInfo")
    public static let infoFilled                  = AssetManager.ImageKey("iconSystemInfoFilled")
    public static let time                        = AssetManager.ImageKey("iconSystemTime")
    public static let date                        = AssetManager.ImageKey("iconSystemDate")
    public static let location                    = AssetManager.ImageKey("iconSystemLocation")
    public static let thumbnail                   = AssetManager.ImageKey("iconSystemThumbnail")
    public static let dropDown                    = AssetManager.ImageKey("iconSystemDropdown")
    public static let disclosure                  = AssetManager.ImageKey("iconSystemDisclosure")
    public static let overflow                    = AssetManager.ImageKey("iconSystemOverflow")
    public static let advancedSearch              = AssetManager.ImageKey("iconSystemAdvancedSearch")
    public static let login                       = AssetManager.ImageKey("iconSystemLogin")
    public static let nightMode                   = AssetManager.ImageKey("iconSystemNightMode")
    public static let keyboard                    = AssetManager.ImageKey("iconSystemKeyboard")
    public static let searchField                 = AssetManager.ImageKey("iconSystemSearchField")

    public static let faceId                      = AssetManager.ImageKey("iconBiometricFaceId")
    public static let touchId                     = AssetManager.ImageKey("iconBiometricTouchId")

    public static let navBarThumbnail             = AssetManager.ImageKey("iconNavBarThumbnail")
    public static let navBarThumbnailSelected     = AssetManager.ImageKey("iconNavBarThumbnailSelected")

    // Media
    public static let play                        = AssetManager.ImageKey("iconMediaPlay")
    public static let audioWave                   = AssetManager.ImageKey("audioWave")
    public static let iconPlay                    = AssetManager.ImageKey("iconPlay")
    public static let iconPause                   = AssetManager.ImageKey("iconPause")
    public static let download                    = AssetManager.ImageKey("download")

    // General
    public static let alert                       = AssetManager.ImageKey("iconGeneralAlert")
    public static let alertFilled                 = AssetManager.ImageKey("iconGeneralAlertFilled")
    public static let association                 = AssetManager.ImageKey("iconGeneralAssociation")
    public static let event                       = AssetManager.ImageKey("iconGeneralEvent")
    public static let document                    = AssetManager.ImageKey("iconGeneralDocument")
    public static let documentFilled              = AssetManager.ImageKey("iconGeneralDocumentFilled")
    public static let direction                   = AssetManager.ImageKey("iconGeneralDirection")
    public static let service                     = AssetManager.ImageKey("iconGeneralService")
    public static let attachment                  = AssetManager.ImageKey("iconGeneralAttachment")
    public static let finalise                    = AssetManager.ImageKey("iconGeneralFinalise")
    public static let tactical                    = AssetManager.ImageKey("iconGeneralTactical")
    public static let journey                     = AssetManager.ImageKey("iconGeneralJourney")
    public static let list                        = AssetManager.ImageKey("iconGeneralList")
    public static let mass                        = AssetManager.ImageKey("iconGeneralMass")
    public static let map                         = AssetManager.ImageKey("iconGeneralMap")
    public static let folder                      = AssetManager.ImageKey("iconFormFolder")
    public static let refresh                     = AssetManager.ImageKey("iconGeneralRefreshMagnify")
    public static let email                       = AssetManager.ImageKey("iconFormEmail")
    public static let duress                      = AssetManager.ImageKey("iconDuress")
    public static let route                       = AssetManager.ImageKey("iconGeneralRoute")
    public static let streetView                  = AssetManager.ImageKey("iconGeneralStreetView")
    public static let clearText                   = AssetManager.ImageKey("iconClearText")

    public static let generalLocation             = AssetManager.ImageKey("iconGeneralLocation")
    public static let otherPatrolArea             = AssetManager.ImageKey("iconOtherPatrolArea")

    // Map
    public static let pinLocation                 = AssetManager.ImageKey("pinLocation")
    public static let pinDefault                  = AssetManager.ImageKey("pinDefault")
    public static let pinCluster                  = AssetManager.ImageKey("pinCluster")

    // Entity
    public static let entityOfficer               = AssetManager.ImageKey("iconEntityOfficer")
    public static let entityPerson                = AssetManager.ImageKey("iconEntityPerson")
    public static let entityBuilding              = AssetManager.ImageKey("iconEntityBuilding")
    public static let entityTruck                 = AssetManager.ImageKey("iconEntityVehicleTruck")
    public static let entityBoat                  = AssetManager.ImageKey("iconEntityAutomotiveWater")

    public static let entityPersonMedium          = AssetManager.ImageKey("iconEntityPerson32")

    public static let entityCarSmall              = AssetManager.ImageKey("iconEntityAutomotiveCarSmall")
    public static let entityCarMedium             = AssetManager.ImageKey("iconEntityAutomotiveCarMedium")
    public static let entityCarLarge              = AssetManager.ImageKey("iconEntityAutomotiveCarLarge")

    public static let entityMotorbikeSmall        = AssetManager.ImageKey("iconEntityAutomotiveMotorbikeSmall")
    public static let entityMotorbikeMedium       = AssetManager.ImageKey("iconEntityAutomotiveMotorbikeMedium")
    public static let entityMotorbikeLarge        = AssetManager.ImageKey("iconEntityAutomotiveMotorbikeLarge")

    public static let entityTruckSmall            = AssetManager.ImageKey("iconEntityVehicleTruckSmall")
    public static let entityTruckMedium           = AssetManager.ImageKey("iconÍEntityVehicleTruckMedium")
    public static let entityTruckLarge            = AssetManager.ImageKey("iconEntityVehicleTruckLarge")

    public static let entityTrailerSmall          = AssetManager.ImageKey("iconEntityAutomotiveTrailerSmall")
    public static let entityTrailerMedium         = AssetManager.ImageKey("iconEntityAutomotiveTrailerMedium")
    public static let entityTrailerLarge          = AssetManager.ImageKey("iconEntityAutomotiveTrailerLarge")

    public static let entityTrailer2Small         = AssetManager.ImageKey("iconEntityAutomotiveTrailer2Small")
    public static let entityTrailer2Medium        = AssetManager.ImageKey("iconEntityAutomotiveTrailer2Medium")
    public static let entityTrailer2Large         = AssetManager.ImageKey("iconEntityAutomotiveTrailer2Large")

    @available(iOS, deprecated, message: "EntityThumbnail now uses themed coloured backgrounds")
    public static let entityPlaceholder           = AssetManager.ImageKey("EntityThumbnailBackground")

    public static let iconEntityVehicleMotorcycle = AssetManager.ImageKey("iconEntityVehicleMotorcycle")

    public static let entityMotorcycleSmall       = AssetManager.ImageKey("iconEntityVehicleMotorcycleSmall")
    public static let entityMotorcycleMedium      = AssetManager.ImageKey("iconEntityVehicleMotorcycleMedium")
    public static let entityMotorcycleLarge       = AssetManager.ImageKey("iconEntityVehicleMotorcycleLarge")

    public static let entityVanSmall              = AssetManager.ImageKey("iconEntityVehicleVanSmall")
    public static let entityVanMedium             = AssetManager.ImageKey("iconEntityVehicleVanMedium")
    public static let entityVanLarge              = AssetManager.ImageKey("iconEntityVehicleVanLarge")

    public static let entityBoatSmall             = AssetManager.ImageKey("iconEntityAutomotiveWaterSmall")
    public static let entityBoatMedium            = AssetManager.ImageKey("iconEntityAutomotiveWaterMedium")
    public static let entityBoatLarge             = AssetManager.ImageKey("iconEntityAutomotiveWaterLarge")

    // Resource
    public static let resourceGeneral             = AssetManager.ImageKey("iconResourceGeneral")
    public static let resourceDevice              = AssetManager.ImageKey("iconResourceDevice")
    public static let resourceCar                 = AssetManager.ImageKey("iconResourceCar")
    public static let resourceWater               = AssetManager.ImageKey("iconResourceWater")
    public static let resourceBicycle             = AssetManager.ImageKey("iconResourceBicycle")
    public static let resourceHelicopter          = AssetManager.ImageKey("iconResourceHelicopter")
    public static let resourceBeat                = AssetManager.ImageKey("iconResourceBeat")
    public static let resourceDog                 = AssetManager.ImageKey("iconResourceDog")// woof woof
    public static let resourceSegway              = AssetManager.ImageKey("iconResourceSegway")

    public static let resourceCarLarge            = AssetManager.ImageKey("icon32ResourceCar")

    // Comms
    public static let commsDevice                 = AssetManager.ImageKey("iconCommsDevice")
    public static let commsEmail                  = AssetManager.ImageKey("iconCommsEmail")
    public static let post                        = AssetManager.ImageKey("iconCommsPost")
    public static let audioCall                   = AssetManager.ImageKey("iconCommsCall")
    public static let videoCall                   = AssetManager.ImageKey("iconCommsVideo")
    public static let message                     = AssetManager.ImageKey("iconCommsMessage")
    public static let gallery                     = AssetManager.ImageKey("iconCommsGallery")

    // Forms
    public static let checkbox                    = AssetManager.ImageKey("iconFormCheckbox")
    public static let checkboxSelected            = AssetManager.ImageKey("iconFormCheckboxSelected")
    public static let radioButton                 = AssetManager.ImageKey("iconFormRadio")
    public static let radioButtonSelected         = AssetManager.ImageKey("iconFormRadioSelected")
    public static let checkmark                   = AssetManager.ImageKey("iconFormCheckmark")

    // Source bar
    public static let sourceBarDownload           = AssetManager.ImageKey("SourceBarDownload")
    public static let sourceBarNone               = AssetManager.ImageKey("SourceBarNone")
    public static let sourceBarMultiple           = AssetManager.ImageKey("iconResourceGeneral")

    // Map
    public static let mapUserLocation             = AssetManager.ImageKey("iconUserLocation")
    public static let mapUserTracking             = AssetManager.ImageKey("iconUserTracking")
    public static let mapUserTrackingWithHeading  = AssetManager.ImageKey("iconUserTrackingWithHeading")
    public static let mapCurrentLocation          = AssetManager.ImageKey("iconCurrentLocation")

    // Loading states
    public static let iconLoadingFailed           = AssetManager.ImageKey("iconLoadingFailed")

    // CAD status
    public static let iconStatusAtIncident        = AssetManager.ImageKey("iconStatusAtIncident")
    public static let iconStatusCourt             = AssetManager.ImageKey("iconStatusCourt")
    public static let iconStatusFinalise          = AssetManager.ImageKey("iconStatusFinalise")
    public static let iconStatusInquiries         = AssetManager.ImageKey("iconStatusInquiries")
    public static let iconStatusMealBreak         = AssetManager.ImageKey("iconStatusMealBreak")
    public static let iconStatusOnAir             = AssetManager.ImageKey("iconStatusOnAir")
    public static let iconStatusOnCall            = AssetManager.ImageKey("iconStatusOnCall")
    public static let iconStatusProceeding        = AssetManager.ImageKey("iconStatusProceeding")
    public static let iconStatusStation           = AssetManager.ImageKey("iconStatusStation")
    public static let iconStatusTrafficStop       = AssetManager.ImageKey("iconStatusTrafficStop")
    public static let iconStatusUnavailable       = AssetManager.ImageKey("iconStatusUnavailable")

    // Events
    public static let iconFolder                  = AssetManager.ImageKey("iconFolder")
    public static let iconPencil                  = AssetManager.ImageKey("iconPencil")
    public static let iconDocument                = AssetManager.ImageKey("iconDocument")
    public static let iconRelationships           = AssetManager.ImageKey("iconGeneralRelationships")
    public static let iconHeaderFinalise          = AssetManager.ImageKey("icon40StatusFinalise")
    public static let iconHeaderEdit              = AssetManager.ImageKey("icon40SystemEdit")
    public static let eventDateTime               = AssetManager.ImageKey("iconSystemDateAndTime")
    public static let eventLocation               = AssetManager.ImageKey("iconEntityLocation")

    // Dialog images
    public static let dialogAlert                 = AssetManager.ImageKey("dialogAlert")

}
