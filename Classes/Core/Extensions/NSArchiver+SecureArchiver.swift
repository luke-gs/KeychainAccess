//
//  NSArchiver.swift
//  MPOLKit
//
//  Created by Herli Halim on 3/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public extension NSKeyedUnarchiver {

    public class func MPL_securelyUnarchiveObject<T>(with data: Data) -> T? where T: NSSecureCoding, T: NSObject {
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        unarchiver.requiresSecureCoding = true
        let object = unarchiver.decodeObject(of: T.self, forKey: NSKeyedArchiveRootObjectKey)

        // Do not force unwrap result, as it will result in fatalError that cannot be caught
        // if the optional init?(coder aDecoder: NSCoder) constructor returns nil
        return object
    }
    
    public class func MPL_securelyUnarchiveObject<T>(from file: String) -> T? where T: NSSecureCoding, T: NSObject {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: file))
            return MPL_securelyUnarchiveObject(with: data)
        } catch {
            return nil
        }
    }
}

public extension NSKeyedArchiver {

    public class func MPL_securelyArchivedData<T: NSSecureCoding>(withRootObject object: T) -> Data {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        
        archiver.requiresSecureCoding = true
        // For some reasons, `encodeRootObject` is a thing, but not the one you want.
        archiver.encode(object, forKey: NSKeyedArchiveRootObjectKey)
        archiver.finishEncoding()
        
        return data as Data
    }
    
    public class func MPL_securelyArchive<T: NSSecureCoding>(rootObject: T, to filePath: String) -> Bool {
        let data = MPL_securelyArchivedData(withRootObject: rootObject)
        do {
            try data.write(to: URL(fileURLWithPath: filePath), options: .atomicWrite)
            return true
        } catch {
            return false
        }
    }
}
