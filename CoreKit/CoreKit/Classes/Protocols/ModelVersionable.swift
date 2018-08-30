//
//  Versionable.swift
//
//
//  Created by Herli Halim on 28/3/17.
//
//

public protocol ModelVersionable {
    
    static var modelVersion: Int { get }

    /// Perform migration of user data when the model version changes
    /// - parameters:
    ///     - from: The previous version
    ///     - to: The new version
    ///     - decoder: The decoder to read values from old object
    /// - throws: if an error occurs performing migration
    /// - returns: true if migration was performed, false if not necessary
    func performMigrationIfNeeded(from: Int, to: Int, decoder: NSCoder) throws -> Bool

}

extension ModelVersionable {
    public static var modelVersion: Int {
        return 0
    }
    
    public func performMigrationIfNeeded(from: Int, to: Int, decoder: NSCoder) throws -> Bool {
        // By default, no migration
        return false
    }
}

/// Enum for model migration errors
public enum ModelVersionableError: Error {
    case migrationNotsupported
}
