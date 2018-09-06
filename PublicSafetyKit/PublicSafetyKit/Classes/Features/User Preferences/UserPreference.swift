//
//  UserPreference.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public class UserPreferenceKey: ExtensibleKey<String> { }

// Representation of the backend PreferenceObject.
public class UserPreference: NSObject, NSSecureCoding, Codable {
 
    public var applicationName: String
    public var preferenceTypeKey: UserPreferenceKey
    public var data: String
    public var mimeType: String
    
    public var isSynchronizedRemotely: Bool?
    
    public var image: UIImage? {
        guard let imageData = Data(base64Encoded: data) else { return nil }
        return UIImage(data: imageData)
    }
    
    public func codables<T: Codable>() -> [T]? {
        guard let encodedData = data.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode([T].self, from: encodedData)
    }
    
    public static var supportsSecureCoding: Bool {
        return true
    }
    
    // MARK: Init
    
    /// Default initializer.
    /// It's assumed that if we're creating a preference using these initilizers its local and hence isSynchonizedRemotely defaults to false
    public init(applicationName: String = User.applicationKey, preferenceTypeKey: UserPreferenceKey, data: String, mimeType: String = "text/plain", isSynchonizedRemotely: Bool? = false) {
        self.applicationName = applicationName
        self.preferenceTypeKey = preferenceTypeKey
        self.data = data
        self.mimeType = mimeType
        self.isSynchronizedRemotely = isSynchonizedRemotely
    }
    
    /// Failable initializer for storing images. Converts the image to a PNGRepresentation before storing as a base64 encoded string
    /// as required by backend
    public convenience init?(applicationName: String = User.applicationKey, preferenceTypeKey: UserPreferenceKey, image: UIImage, isSynchonizedRemotely: Bool? = false) {
        guard let imageData = UIImagePNGRepresentation(image) else { return nil }
        
        self.init(applicationName: applicationName,
                  preferenceTypeKey: preferenceTypeKey,
                  data: imageData.base64EncodedString(),
                  mimeType: "image/png",
                  isSynchonizedRemotely: isSynchonizedRemotely)
    }
    
    /// Initializer for a JSON object. Sets the correct mimetype and converts the data into a UTF-8 string for storage.
    /// Can be retrieved by calling the instance method encodables with the same type.
    public convenience init?<T:Codable>(applicationName: String = User.applicationKey, preferenceTypeKey: UserPreferenceKey, codables: [T], isSynchonizedRemotely: Bool? = false) throws {
        let jsonData = try JSONEncoder().encode(codables)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else { return nil }
        self.init(applicationName: applicationName,
                  preferenceTypeKey: preferenceTypeKey,
                  data: jsonString,
                  mimeType: "application/json",
                  isSynchonizedRemotely: isSynchonizedRemotely)
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case applicationName
        case preferenceTypeKey
        case data
        case mimeType
        case isSynchonizedRemotely
    }
    
    // MARK: Decoding
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let applicationName = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.applicationName.rawValue)! as String
        let rawPreferenceIdentifier = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.preferenceTypeKey.rawValue)! as String
        let data = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.data.rawValue)! as String
        let mimeType = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.mimeType.rawValue)! as String
        let isSynchonizedRemotely = aDecoder.decodeBool(forKey: CodingKeys.isSynchonizedRemotely.rawValue)
        
        self.init(applicationName: applicationName,
                  preferenceTypeKey: UserPreferenceKey(rawPreferenceIdentifier),
                  data: data,
                  mimeType: mimeType,
                  isSynchonizedRemotely: isSynchonizedRemotely)
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        applicationName = try values.decode(String.self, forKey: .applicationName)
        preferenceTypeKey = UserPreferenceKey(try values.decode(String.self, forKey: .preferenceTypeKey))
        data = try values.decode(String.self, forKey: .data)
        mimeType = try values.decode(String.self, forKey: .mimeType)
        isSynchronizedRemotely = try values.decodeIfPresent(Bool.self, forKey: .isSynchonizedRemotely)
    }
    
    // MARK: Encoding
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(applicationName, forKey: CodingKeys.applicationName.rawValue)
        aCoder.encode(preferenceTypeKey.rawValue, forKey: CodingKeys.preferenceTypeKey.rawValue)
        aCoder.encode(data, forKey: CodingKeys.data.rawValue)
        aCoder.encode(mimeType, forKey: CodingKeys.mimeType.rawValue)
        if let safeSync = isSynchronizedRemotely {
            aCoder.encode(safeSync, forKey: CodingKeys.isSynchonizedRemotely.rawValue)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(applicationName, forKey: .applicationName)
        try container.encode(preferenceTypeKey.rawValue, forKey: .preferenceTypeKey)
        try container.encode(data, forKey: .data)
        try container.encode(mimeType, forKey: .mimeType)
        try container.encode(isSynchronizedRemotely, forKey: .isSynchonizedRemotely)
    }
}
