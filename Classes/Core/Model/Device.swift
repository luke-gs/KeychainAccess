//
//  Device.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 10/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Class for representing device unique information
public class Device {

    // The current device
    public static let current = Device()

    // Use the app group user defaults for sharing between apps by default
    public static var userDefaults: UserDefaults = AppGroupCapability.appUserDefaults

    // User defaults key for device UUID
    public static let deviceUuidKey = "DeviceUuidKey"

    /// The UUID for this device, to be used with backend services
    public var deviceUuid: String {
        // Fetch from app group user defaults
        var deviceUuid = Device.userDefaults.string(forKey: Device.deviceUuidKey)
        if deviceUuid == nil {
            // Not found, generate uuid and store
            deviceUuid = UUID().uuidString
            Device.userDefaults.set(deviceUuid, forKey: Device.deviceUuidKey)
        }
        return deviceUuid!
    }

}
