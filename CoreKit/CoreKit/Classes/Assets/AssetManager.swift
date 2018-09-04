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

    /// The default bundle to search for assets
    public static var defaultBundle = Bundle(for: AssetManager.self)
    
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

        // TODO: refactor to allow bundle registration
        return UIImage(named: key.rawValue, in: AssetManager.defaultBundle, compatibleWith: traitCollection)
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
    }
}

public func == (lhs: AssetManager.ImageKey, rhs: AssetManager.ImageKey) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
