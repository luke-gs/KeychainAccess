//
//  Manifest.swift
//  MPOLKit
//
//  Created by Rod Brown on 27/10/16.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit

fileprivate let manifestLastUpdateKey = "Manifest_LastUpdate"

public extension NSNotification.Name {
    
    static let ManifestDidUpdate = NSNotification.Name(rawValue: "ManifestDidUpdate")
}

struct ManifestError: LocalizedError {
    var errorDescription: String? = nil
    var failureReason: String? = nil
    var recoverySuggestion: String?  = nil
    var helpAnchor: String? = nil
    
    init(_ description: String, reason: String? = nil, recovery: String? = nil, anchor: String? = nil)
    {
        errorDescription = description
        failureReason = reason
        recoverySuggestion = recovery
        helpAnchor = anchor
    }
}

private enum ManifestItemKeys: String {
    case active = "active"
    case collection = "category"
    case title = "title"
    case subtitle = "subtitle"
    case shortTitle = "shortTitle"
    case rawValue = "value"
    case sortOrder = "sortOrder"
    case effectiveDate = "effectiveDate"
    case expiryDate = "expiryDate"
    case dateLastUpdated = "dateLastUpdated"
    case additionalData = "additionalData"
    case latitude = "latitude"
    case longitude = "longitude"
}

public final class Manifest: NSObject {
    
    private static var storageDirectory: URL = {
        let fileManager = FileManager.default
        
        let directoryURL = try! fileManager.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("Manifest", isDirectory: true)
        if fileManager.fileExists(at: directoryURL) == false {
            try! fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            UserDefaults.standard.setValue(nil, forKey: manifestLastUpdateKey)
        }
        
        return directoryURL
    }()
    
    private static var storageURL = storageDirectory.appendingPathComponent("Manifest.sqlite", isDirectory: false)
    
    /// The singleton shared manifest. This is the only instance of this class.
    public static let shared = Manifest()
    
    private let managedObjectModel:         NSManagedObjectModel
    private let persistentStoreCoordinator: NSPersistentStoreCoordinator
    
    /// The view context for the manifest. This should only be accessed from the main thread.
    public let viewContext: NSManagedObjectContext
    
    public fileprivate(set) var lastUpdateDate: Date? {
        get {
            if FileManager.default.fileExists(at: Manifest.storageURL) {
                return UserDefaults.standard.object(forKey: manifestLastUpdateKey) as? Date
            } else {
                UserDefaults.standard.setValue(nil, forKey: manifestLastUpdateKey)
            }
            return nil
        }
        set { UserDefaults.standard.set(newValue, forKey: manifestLastUpdateKey) }
    }
    
    private override init() {
        let modelLocation          = Bundle(for: Manifest.self).url(forResource: "Manifest", withExtension: "momd")!
        managedObjectModel         = NSManagedObjectModel(contentsOf: modelLocation)!
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        try! persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: Manifest.storageURL, options: [NSSQLitePragmasOption: ["journal_mode": "DELETE"]])
        
        viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        viewContext.shouldDeleteInaccessibleFaults = true
        viewContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextDidSave(_:)), name: .NSManagedObjectContextDidSave, object: nil)
    }
    
    // MARK: - Pre-seed
    
    /// Copies file (hopefully the pre-seeded sql file) to the current manifest path. Use as a pre-seed in order to avoid massive initial downloads. Recommended you do this before your first manifest fetch.
    ///
    /// - Parameters:
    ///   - copyUrl:               The URL at which the pre-seeded manifest is kept.
    ///   - seedDate:              The date of the pre-seed. Used for future fetches.
    /// - Returns:                 returns a Void Promise, will fail in case the copy is unsuccessful or the override is unsuccessful.
    public func preseedDatebase(withURL copyUrl: URL, seedDate: Date) -> Promise<Void> {
        return Promise { fulfill, reject in
            let finalURL = Manifest.storageURL
            let fileManager = FileManager.default
            
            if fileManager.fileExists(at: finalURL) {
                do {
                    try fileManager.removeItem(at: finalURL)
                } catch let error {
                    reject(error)
                }
            }
            
            do {
                try fileManager.copyItem(atPath: copyUrl.path, toPath: finalURL.path)
                lastUpdateDate = seedDate
                fulfill(())
            } catch let error {
                reject(error)
            }
        }
    }
    
    
    // MARK: - Fetch Methods
    
    /// Fetches all entries in a collection, with optional start dates, end dates, and additional predicates.
    ///
    /// - Parameters:
    ///   - collection:          The collection to search for.
    ///   - activeOnly:          Indicates whether to only check for active entries. The default is `true`.
    ///   - date:                The date to check when effective. The default is `nil`.
    ///   - additionalPredicate: An optional additional predicate to further refine the search.
    ///   - descriptors:         Optional sort descriptors for the fetch. The default sorts by the `sortOrder` property.
    /// - Returns:      An `NSFetchRequest` instance, configured to fetch all entries matching the required details.
    public func fetchRequest(forEntriesIn collection: ManifestCollection,
                             activeOnly: Bool = true,
                             effectiveAt date: Date? = nil,
                             additionalPredicate: NSPredicate? = nil,
                             sortedBy descriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: "sortOrder", ascending: true)]) -> NSFetchRequest<ManifestEntry> {
        let request: NSFetchRequest<ManifestEntry> = ManifestEntry.fetchRequest()
        
        var predicates = [NSPredicate(format: "collection == %@", collection.rawValue)]
        
        if activeOnly {
            predicates.append(NSPredicate(format: "active == YES"))
        }
        if let date = date {
            predicates.append(NSPredicate(format: "expiryDate == nil OR expiryDate > %@", date as NSDate))
            predicates.append(NSPredicate(format: "effectiveDate == nil OR effectiveDate <= %@", date as NSDate))
        }
        if let additionalPredicate = additionalPredicate {
            predicates.append(additionalPredicate)
        }
        
        if predicates.count == 1 {
            request.predicate = predicates.first
        } else {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        request.sortDescriptors = descriptors
        
        return request
    }
    
    
    /// Creates a fetch request for an entry with the associated ID.
    ///
    /// - Parameter id: The ID to search for.
    /// - Returns:      An `NSFetchRequest` instance, configured to fetch the required entry.
    public func fetchRequest(forEntryWithID id: String) -> NSFetchRequest<ManifestEntry> {
        let request: NSFetchRequest<ManifestEntry> = ManifestEntry.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        return request
    }
    
    
    // MARK: - Convenience methods
    
    /// Fetches all entries in a collection, if they exist, in the `viewContext`.
    ///
    /// - Parameter collection:
    /// - Returns: An array of `ManifestEntry` items matching the collection, or nil.
    ///
    /// - Parameters:
    ///   - collection:   The collection to fetch results for.
    ///   - activeOnly:   Indicates whether fetches should only return those items that are not inactive. The default is `true`.
    ///   - descriptors:  Optional sort descriptors to apply to the entries. The default sorts by the "sortOrder" property.
    /// - Returns: All entries in the collection.
    public func entries(for collection: ManifestCollection, activeOnly: Bool = true,
                        sortedBy descriptors: [NSSortDescriptor]? = [NSSortDescriptor(key: "sortOrder", ascending: true)]) -> [ManifestEntry]? {
        let request = fetchRequest(forEntriesIn: collection, activeOnly: activeOnly, sortedBy: descriptors)
        return try? viewContext.fetch(request)
    }
    
    
    /// Fetches an entry with the associated ID, if it exists, in the `viewContext`.
    ///
    /// - Parameter id: The ID to search for.
    /// - Returns: The associated `ManifestEntry` item, if it exists, or nil.
    public func entry(withID id: String) -> ManifestEntry? {
        let request = fetchRequest(forEntryWithID: id)
        let result = try? viewContext.fetch(request)
        
        return result?.first
    }
    
    
    // MARK: - Notification support
    
    /// Managed object save notification handler. This method should only be called by the default `NotificationCenter`,
    /// and handles migrating changes from other contexts with the shared persistent store back into the `viewContext`.
    ///
    /// - Parameter notification: The notification posted to the NotificationCenter.
    @objc
    private func managedObjectContextDidSave(_ notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext,
            context != viewContext && context.persistentStoreCoordinator == persistentStoreCoordinator else { return }
        
        DispatchQueue.main.async {
            self.viewContext.mergeChanges(fromContextDidSave: notification)
            NotificationCenter.default.post(name: .ManifestDidUpdate, object: self)
        }
    }
    
    public static let dateFormatter:ISO8601DateFormatter = ISO8601DateFormatter()
    public private(set) var currenUpdatingPromise:Promise<Void>? = nil
    public private(set) var isSaving:Bool = false
    
    // MARK: - Save manifest
    
    /// Save dictionary of manifest items to the coredata table
    ///
    /// - Parameters:
    ///     - ManifestItems: a dictionary of items to be saved
    ///     - checkAtDate: the time/date the manifest was retrieved
    /// - Return: A promise that returns the successful result once complete
    ///
    public func saveManifest(with manifestItems:[[String : Any]], at checkedAtDate:Date) -> Promise<Void> {
        return Promise<Void> { fulfill, reject in
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            if isSaving == true {
                reject(ManifestError("Already saving, please try again later"))
                return
            }
            isSaving = true
            let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
            managedObjectContext.perform { [weak managedObjectContext] in
                guard manifestItems.isEmpty ==  false, let context = managedObjectContext else {
                    fulfill(())
                    return
                }
                
                for entryDict in manifestItems {
                    guard let id = entryDict["id"] as? String else { continue }
                    
                    autoreleasepool {
                        let entry: ManifestEntry
                        
                        if let foundEntry = (try? context.fetch(self.fetchRequest(forEntryWithID: id)))?.first {
                            entry = foundEntry
                        } else {
                            entry = ManifestEntry(context: context)
                            entry.id = id
                        }
                        
                        entry.active        = entryDict[ManifestItemKeys.active.rawValue]     as? Bool ?? false
                        entry.collection    = entryDict[ManifestItemKeys.collection.rawValue]   as? String
                        entry.title         = entryDict[ManifestItemKeys.title.rawValue]      as? String
                        entry.subtitle      = entryDict[ManifestItemKeys.subtitle.rawValue]   as? String
                        entry.shortTitle    = entryDict[ManifestItemKeys.shortTitle.rawValue] as? String
                        entry.rawValue      = entryDict[ManifestItemKeys.rawValue.rawValue]      as? String
                        entry.sortOrder     = entryDict[ManifestItemKeys.sortOrder.rawValue]  as? Double ?? 0
                        
                        if let effectiveDateString = entryDict[ManifestItemKeys.effectiveDate.rawValue] as? String {
                            if let date = Manifest.dateFormatter.date(from: effectiveDateString) as Date? {
                                entry.effectiveDate = date
                            }
                        }
                        
                        if let expiryDateString = entryDict[ManifestItemKeys.expiryDate.rawValue] as? String {
                            if let date = Manifest.dateFormatter.date(from: expiryDateString) as Date? {
                                entry.expiryDate = date
                            }
                        }
                        
                        if let dateLastUpdated = entryDict[ManifestItemKeys.dateLastUpdated.rawValue] as? String {
                            if let date = Manifest.dateFormatter.date(from: dateLastUpdated) as Date? {
                                entry.lastUpdated = date
                            }
                        }
                        
                        if var additionalData = entryDict[ManifestItemKeys.additionalData.rawValue] as? [String: Any] {
                            
                            if let latitude = additionalData[ManifestItemKeys.latitude.rawValue] as? NSNumber {
                                entry.latitude = latitude
                                additionalData.removeValue(forKey: ManifestItemKeys.latitude.rawValue)
                            }
                            if let longitude = additionalData[ManifestItemKeys.longitude.rawValue] as? NSNumber {
                                entry.longitude = longitude
                                additionalData.removeValue(forKey: ManifestItemKeys.longitude.rawValue)
                            }
                            
                            entry.additionalDetails = additionalData
                        }
                    }
                }
                
                do {
                    try context.save()
                        self.lastUpdateDate = checkedAtDate
                        fulfill(())
                        self.isSaving = false
                } catch let error {
                        reject(error)
                        self.isSaving = false
                }
            }
            
        }
    }
    
    // MARK: - Update manifest
    
    /// Uses the APIManager to connect and retrive the latest manifest, using the lastUpdateDate as a Delta
    ///
    /// - Return: A promise that returns the successful result once complete
    ///
    public func update() -> Promise<Void> {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if let currentPromise = self.currenUpdatingPromise {
            return currentPromise
        } else {
            let checkedAtDate = Date()
            
            /// Remove 60 seconds from any last date to ensure we get an overlap.
            /// It's better to catch more items and update them again than to miss any. This may change in the back end later for the server to handle this buffer.. or return a time stamp for the updated time.
            let newPromise = APIManager.shared.fetchManifest(for: self.lastUpdateDate?.addingTimeInterval(-60.0)).then { [weak self] result -> Promise<Void> in
                guard let `self` = self else { return Promise<Void>(value: ()) }
                guard result.isEmpty == false else {
                    self.lastUpdateDate = checkedAtDate
                    return Promise<Void>(value: ())
                }
                
                return self.saveManifest(with: result, at:checkedAtDate)
                
                }.always { [weak self] in
                    guard let `self` = self else { return }
                    self.currenUpdatingPromise = nil
            }
            self.currenUpdatingPromise = newPromise
            return newPromise
        }
    }
}

