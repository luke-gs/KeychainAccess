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
    
    public private(set) var isUpdating:Bool = false
        
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
    
    public func saveManifest(with manifestItems:[[String : Any]], at checkedAtDate:Date, completion: ((Error?) -> Void)?) {
        if isUpdating == false {
            do {
                self.isUpdating = true
                let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
                managedObjectContext.perform { [weak managedObjectContext] in
                    guard manifestItems.isEmpty ==  false, let context = managedObjectContext else { return }
                    
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
                            
                            entry.active        = entryDict["active"]     as? Bool ?? false
                            entry.collection    = entryDict["category"]   as? String
                            entry.title         = entryDict["title"]      as? String
                            entry.subtitle      = entryDict["subtitle"]   as? String
                            entry.shortTitle    = entryDict["shortTitle"] as? String
                            entry.rawValue      = entryDict["value"]      as? String
                            entry.sortOrder     = entryDict["sortOrder"]  as? Double ?? 0
                            
                            if let effectiveDateString = entryDict["effectiveDate"] as? String {
                                if let date = Manifest.dateFormatter.date(from: effectiveDateString) as NSDate? {
                                    entry.effectiveDate = date
                                }
                            }
                            
                            if let expiryDateString = entryDict["expiryDate"] as? String {
                                if let date = Manifest.dateFormatter.date(from: expiryDateString) as NSDate? {
                                    entry.expiryDate = date
                                }
                            }
                            
                            if let dateLastUpdated = entryDict["dateLastUpdated"] as? String {
                                if let date = Manifest.dateFormatter.date(from: dateLastUpdated) as NSDate? {
                                    entry.lastUpdated = date
                                }
                            }
                            
                            if var additionalData = entryDict["additionalData"] as? [String: Any] {
                                
                                if let latitude = additionalData["latitude"] as? NSNumber {
                                    entry.latitude = latitude
                                    additionalData.removeValue(forKey: "latitude")
                                }
                                if let longitude = additionalData["longitude"] as? NSNumber {
                                    entry.longitude = longitude
                                    additionalData.removeValue(forKey: "longitude")
                                }
                                
                                entry.additionalDetails = additionalData
                            }
                        }
                    }
                    
                    do {
                        self.isUpdating = false
                        try context.save()
                        
                        DispatchQueue.main.async {
                            self.lastUpdateDate = checkedAtDate
                            completion?(nil)
                        }
                    } catch let error {
                        DispatchQueue.main.async {
                            completion?(error)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Update manifest
    
    /// Uses the APIManager to connect and retrive the latest manifest, using the lastUpdateDate as a Delta
    ///
    /// - Parameter completion: returns an error if any
    public func update(completion: ((Error?) -> Void)?) {
        if isUpdating == false {
            let checkedAtDate = Date()
            isUpdating = true
            
            /// Remove 60 seconds from any last date to ensure we get an overlap.
            /// It's better to catch more items and update them again than to miss any.
            APIManager.shared.fetchManifest(for: lastUpdateDate?.addingTimeInterval(-60.0)).then { [weak self] result -> Void in
                guard let `self` = self else { return }
                guard result.isEmpty == false else {
                    DispatchQueue.main.async {
                        self.isUpdating = false
                        self.lastUpdateDate = checkedAtDate
                        completion?(nil)
                    }
                    return
                }
                
                self.isUpdating = false
                self.saveManifest(with: result, at:checkedAtDate, completion: completion)
                
                }.catch { error in
                    self.isUpdating = false
                    completion?(error)
            }
        }
    }
    
}

