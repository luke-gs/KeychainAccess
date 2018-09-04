//
//  AssetManager.swift
//  CoreKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//
import UIKit

/// Generic Asset Manager for managing asset loading in complex apps.
///
/// The asset manager allows you to access the assets contained within different bundles
/// spread across the app.
///
/// When loading assets, individual asset overrides are first checked by asset key.
/// If no override is found each bundle that has been registered will be searched in
/// priority order until the item is found or return nil.
public class AssetManager {
    
    /// The shared asset manager singleton.
    public static let shared: AssetManager = AssetManager()

    /// Default init that uses this module by default to load assets
    public init() {
        register(bundle: Bundle(for: AssetManager.self), priority: .coreKit)
    }

    // MARK: - Bundle Registration

    /// The priority order of using a bundle, similar to UILayoutPriority. Higher value is higher priority
    public class BundlePriority: ExtensibleKey<Int> {
        public static let coreKit = AssetManager.BundlePriority(100)
    }

    /// Register an asset bundle with a given priority.
    ///
    /// If an existing bundle is already registered with the same priority,
    /// the previously registered bundle will take precedence.
    ///
    /// - Parameters:
    ///   - bundle:   The bundle containing the asset catalogue or file.
    ///   - priority: The priority of this bundle when loading assets.
    public func register(bundle: Bundle, priority: BundlePriority) {
        // Insert bundle in sorted position based on priority
        let bundleRegistration = BundleRegistration(bundle: bundle, priority: priority)
        if let insertPos = registeredBundles.index(where: { $0.priority.rawValue < priority.rawValue }) {
            registeredBundles.insert(bundleRegistration, at: insertPos)
        } else {
            registeredBundles.append(bundleRegistration)
        }
    }

    // MARK: - Asset Registration
    
    /// Unique identifier for an asset. The raw value is either the name of an asset in an asset catalog or a filename
    /// of a resource in the app.
    ///
    /// Extensions to AssetKey should be defined in the module where the asset exists.
    /// eg.
    /// ```
    /// extension AssetManager.AssetKey {
    ///   public static let myImage = AssetManager.AssetKey("myImage")
    /// }
    /// ```
    public class AssetKey: ExtensibleKey<String> { }

    /// Register an individual asset for a given key. You can provide an additional asset name here along with the
    /// key in case the asset has a different name in the bundle being registered.
    ///
    /// - Parameters:
    ///   - name:   The asset catalogue or file name within the specified bundle.
    ///   - bundle: The bundle containing the asset catalogue or file.
    ///   - key:    The AssetKey to register for.
    public func registerAsset(named name: String, in bundle: Bundle, forKey key: AssetKey) {
        registeredAssets[key] = AssetRegistration(bundle: bundle, name: name)
    }

    // MARK: - Asset Loading

    /// Fetch an image asset from the registered assets and bundles. Returns nil if not found.
    ///
    /// - Parameters:
    ///   - key:             The image key to fetch.
    ///   - traitCollection: The trait collection to fetch the asset for. The default is `nil`.
    /// - Returns: A `UIImage` instance if one could be found matching the criteria, or `nil`.
    public func image(forKey key: ImageKey, compatibleWith traitCollection: UITraitCollection? = nil) -> UIImage? {

        // First check for individual asset override
        if let asset = registeredAssets[key],
            let image = UIImage(named: asset.name, in: asset.bundle, compatibleWith: traitCollection) {
            return image
        }

        // Otherwise check the registered bundles, in order
        for registeredBundle in registeredBundles {
            if let image = UIImage(named: key.rawValue, in: registeredBundle.bundle, compatibleWith: traitCollection) {
                return image
            }
        }
        return nil
    }

    // MARK: - Backwards compatibility

    // For backwards compatibility with existing code...
    public typealias ImageKey = AssetKey

    public func registerImage(named name: String, in bundle: Bundle, forKey key: ImageKey) {
        registerAsset(named: name, in: bundle, forKey: key)
    }

    // MARK: - Internal

    /// Represents a bundle registration
    private struct BundleRegistration {
        let bundle: Bundle
        let priority: BundlePriority
    }

    /// Represents a single asset registration
    private struct AssetRegistration {
        let bundle: Bundle
        let name: String
    }

    /// Registered bundles for loading assets, in order with highest priority first
    private var registeredBundles: [BundleRegistration] = []

    /// Individual registered images
    private var registeredAssets: [ImageKey: AssetRegistration] = [:]
}
