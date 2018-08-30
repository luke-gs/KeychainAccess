//
//  UserPreferenceManager.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

extension Notification.Name {
    public static let userPreferencesDidChange = Notification.Name("UserPreferencesDidChange")
}

open class UserPreferenceManager {
    
    public static let shared = UserPreferenceManager()
    
    public static let userPreferenceStorageKey = "UserPreferences"
    
    // MARK - Local operations
    
    /// Fetches a dictionary of local preferences keyed by their UserPreferenceKey
    open func userPreferences() -> [UserPreferenceKey: UserPreference]? {
        guard let stringDict = localUserPreferences() else { return nil }
        var keyDict = [UserPreferenceKey: UserPreference]()
        stringDict.forEach {
            keyDict[UserPreferenceKey($0)] = $1
        }
        return keyDict
    }
    
    /// Fetches an individual local preference
    open func preference(for key: UserPreferenceKey) -> UserPreference? {
        guard let preferences = userPreferences() else { return nil }
        return preferences[key]
    }
    
    /// Saves the user preference to local disk
    open func saveUserPreferenceLocally(_ userPreference: UserPreference) throws {
        precondition(UserSession.current.userStorage != nil, "No current user storage")
        var preferences = localUserPreferences() ?? [String: UserPreference]()
        preferences[userPreference.preferenceTypeKey.rawValue] = userPreference
        try UserSession.current.userStorage!.add(object: preferences as Any, key: UserPreferenceManager.userPreferenceStorageKey, flag: .session)
    }
    
    // MARK: Recent Ids
    
    /// Adds a recent ID to the User Preference store
    ///
    /// - Parameters:
    ///   - id: the ID to insert
    ///   - key: the key of the preference
    ///   - trim: the max number of elements to keep in the array, default is `100`
    open func addRecentId(_ id: String, forKey key: UserPreferenceKey, trimToMaxElements trim: Int = 100) throws {
        try addRecentIds([id], forKey: key, trimToMaxElements: trim)
    }
    
    /// Adds an array of recent IDs to the User Preference store
    ///
    /// - Parameters:
    ///   - ids: the IDs to insert
    ///   - key: the key of the preference
    ///   - trim: the max number of elements to keep in the array, default is `100`
    open func addRecentIds(_ ids: [String], forKey key: UserPreferenceKey, trimToMaxElements trim: Int = 100) throws {
        // ensure we have Ids to avoid wiping the key's data
        guard !ids.isEmpty else { return }
        let recentIds: [String] = trimmedPreferenceArray(ids, forKey: key, trimToMaxElements: trim)
        
        // Save the updated preference
        if let userPreference = try UserPreference(preferenceTypeKey: key, codables: recentIds) {
            try updatePreference(userPreference)
        }
    }
    
    // MARK - Remote operations
    
    /// Fetches preferences for all keys given and saves them locally on disk
    /// This is a convenience method for when the user sessions begins fresh
    /// and we want to retrieve and save all the preferences we care about.
    ///
    /// - Parameters:
    ///   - application: application Key
    ///   - preferenceKeys: array of preference identifiers
    /// - Returns: voided promise
    open func fetchUserPreferences(application: String, preferenceKeys: [UserPreferenceKey]) -> Promise<Void> {
        let promises: [Promise<Void>] = preferenceKeys.map {
            let fetchRequest = UserPreferenceFetchRequest(applicationName: application, preferenceTypeKey: $0)
            return APIManager.shared.fetchUserPreferences(with: fetchRequest).map(saveUserPreferenceLocally)
        }
        
        return when(resolved: promises).asVoid()
    }
    
    /// Synchronizes all preferences that have not been successfully synced remotely.
    ///
    /// - Returns: A voided promise
    open func synchronizeUserPreferencesIfRequired() -> Promise<Void> {
        // No preferences to sync
        guard let userPreferences = UserPreferenceManager.shared.userPreferences() else { return Promise<Void>() }
        
        let unsynchronizedUserPreferences = userPreferences.values.filter {
            let isSynchronized = $0.isSynchronizedRemotely ?? false
            return !isSynchronized
        }
        
        return synchronizeUserPreferences(preferences: unsynchronizedUserPreferences, mergeStrategy: self.mergePreferences)
    }
    
    
    /// Synchronizes all preferences.
    /// Fetches the preferences from remote,
    /// applies merge strategy with it and the local copy,
    /// saves the result remotely if required.
    /// - Parameters:
    ///   - preferences: Array of preferences to synchonize
    ///   - mergeStrategy: a closure that takes a local and remote preference and returns a preference to save
    open func synchronizeUserPreferences(preferences: [UserPreference],
                                           mergeStrategy: @escaping (_ local: UserPreference, _ remote: UserPreference) -> UserPreference ) -> Promise<Void> {
        let syncPromise: [Promise<Void>] = preferences.map { localPreference in
            let userPreferenceRequest = UserPreferenceFetchRequest(applicationName: localPreference.applicationName, preferenceTypeKey: localPreference.preferenceTypeKey)
            return APIManager.shared.fetchUserPreferences(with: userPreferenceRequest).then { remotePreference -> Promise<UserPreference> in
                let mergeResult = mergeStrategy(localPreference, remotePreference)
                // Only store preference if we don't decide to use the remote copy.
                guard remotePreference != mergeResult else { return .value(remotePreference)}
                
                //Store user prefs returns and voided promise, so we return the locally referenced merge result
                return APIManager.shared.storeUserPreference(UserPreferenceStoreRequest(localPreference)).then { _ in
                    return Promise<UserPreference>.value(mergeResult)
                }
            }.done { synchronizedPreference in
                synchronizedPreference.isSynchronizedRemotely = true
                try self.saveUserPreferenceLocally(synchronizedPreference)
            }
        }
        
        return when(resolved: syncPromise).asVoid()
        
    }
    
    /// A method to implement a merge strategy when a clash is detected
    /// Currently just returns local which works while the user is handling/using
    /// one device only as their local copy will always be the most up to date
    /// In the future we can use the data's last updated to help decide
    ///
    /// - Parameters:
    ///   - local: the local preference
    ///   - remote: the remote preference
    /// - Returns: the result of the merge.
    open func mergePreferences(local: UserPreference, remote: UserPreference) -> UserPreference {
        return local
    }
    
    /// Updates both the local and remote userPreference store.
    /// - Parameter userPreference: the user preference to store
    open func updatePreference(_ userPreference: UserPreference) throws {
        // Save local preference before remote call to keep preferences updated synchronous
        userPreference.isSynchronizedRemotely = false
        try self.saveUserPreferenceLocally(userPreference)
        synchronizeUserPreferencesIfRequired().cauterize()
    }
    
    // MARK: Private
    
    /// Fetches a dictionary of the local preferences keys by string representations of UserPreferenceKey
    private func localUserPreferences() -> [String: UserPreference]? {
        precondition(UserSession.current.userStorage != nil, "No current user storage")
        return UserSession.current.userStorage!.retrieve(key: UserPreferenceManager.userPreferenceStorageKey) as? [String: UserPreference]
    }
    
    /// Takes an array of ids and adds them to a user preference, trimmed.
    private func trimmedPreferenceArray(_ ids: [String], forKey key: UserPreferenceKey, trimToMaxElements trim: Int = 100) -> [String]  {
        var recent: [String]
        recent = preference(for: key)?.codables() ?? []
        for recentId in ids {
            if let indexOfExisting = recent.index(of: recentId) {
                recent.remove(at: indexOfExisting)
            }
            recent.insert(recentId, at: 0)
            
            recent = Array(recent.prefix(trim))
        }
        return recent
    }
}

