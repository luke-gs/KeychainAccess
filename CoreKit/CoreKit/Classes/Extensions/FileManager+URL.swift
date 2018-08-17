//
//  FileManager+URL.swift
//  MPOLKit
//
//  Created by Rod Brown on 20/1/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

extension FileManager {
    
    public func fileExists(at url: URL, isDirectory: UnsafeMutablePointer<ObjCBool>? = nil) -> Bool {
        guard url.isFileURL else { return false }
        return fileExists(atPath: url.path, isDirectory: isDirectory)
    }
    
}
