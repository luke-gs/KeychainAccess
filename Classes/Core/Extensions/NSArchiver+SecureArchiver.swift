//
//  NSArchiver.swift
//  MPOLKit
//
//  Created by Herli Halim on 3/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public extension NSKeyedUnarchiver {

    public func MPL_securelyUnarchiveObject<T>(with data: Data) -> T where T: NSSecureCoding, T: NSObject {
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        unarchiver.requiresSecureCoding = true
        return unarchiver.decodeObject(of: T.self, forKey: NSKeyedArchiveRootObjectKey)!
    }
    
    public func MPL_securelyUnarchiveObject<T>(withFile: String) -> T? where T: NSSecureCoding, T: NSObject {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: withFile))
            return MPL_securelyUnarchiveObject(with: data)
        } catch {
            return nil
        }
    }
}

public extension NSKeyedArchiver {

    public func MPL_securelyArchivedData<T: NSSecureCoding>(withRootObject object: T) -> Data {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        
        archiver.requiresSecureCoding = true
        // For some reasons, `encodeRootObject` is a thing, but not the one you want.
        archiver.encode(object, forKey: NSKeyedArchiveRootObjectKey)
        archiver.finishEncoding()
        
        return data as Data
    }
    
    public func MPL_securelyArchive<T: NSSecureCoding>(rootObject: T, toFile filePath: String) -> Bool {
        let data = MPL_securelyArchivedData(withRootObject: rootObject)
        do {
            try data.write(to: URL(fileURLWithPath: filePath), options: .atomicWrite)
            return true
        } catch {
            return false
        }
    }
}
