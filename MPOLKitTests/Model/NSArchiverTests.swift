//
//  NSArchiverTests.swift
//  MPOLKitTests
//
//  Created by Herli Halim on 3/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

@objc(MPLSecureTestArchiverObject) private class SecureTestArchiverObject: NSObject, NSSecureCoding {
    
    @objc let testingProperty: String
    
    init(testingProperty: String) {
        self.testingProperty = testingProperty
    }
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(testingProperty, forKey: #keyPath(testingProperty))
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let testingProperty = aDecoder.decodeObject(of: NSString.self, forKey: #keyPath(testingProperty)) as String? else {
            return nil
        }
        self.testingProperty = testingProperty
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let compared = object as? SecureTestArchiverObject else {
            return false
        }
        return self.testingProperty == compared.testingProperty
    }
}

@objc(MPLTestArchiverObject) private class TestArchiverObject: NSObject, NSSecureCoding {
    
    @objc let testingProperty: String
    
    init(testingProperty: String) {
        self.testingProperty = testingProperty
    }
    
    static var supportsSecureCoding: Bool {
        return false
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(testingProperty, forKey: #keyPath(testingProperty))
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let testingProperty = aDecoder.decodeObject(forKey: #keyPath(testingProperty)) as! String? else {
            return nil
        }
        self.testingProperty = testingProperty
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let compared = object as? TestArchiverObject else {
            return false
        }
        return self.testingProperty == compared.testingProperty
    }
}

// Make sure the `test object` is tested
class SecureArchiverObjectTests: XCTestCase {
    func testSupportsSecureCoding() {
        let supports = SecureTestArchiverObject.supportsSecureCoding
        XCTAssertTrue(supports)
    }
    
    func testBinarySerialization() {
        let object = SecureTestArchiverObject(testingProperty: "Hello")
        
        let cloned = self.clone(object: object)
        XCTAssertEqual(object, cloned)
    }
}

class ArchiverObjectTests: XCTestCase {

    func testSupportsSecureCoding() {
        let supports = TestArchiverObject.supportsSecureCoding
        XCTAssertFalse(supports)
    }
    
    func testBinarySerialization() {
        let object = TestArchiverObject(testingProperty: "Hello")
        
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        let cloned = NSKeyedUnarchiver.unarchiveObject(with: data) as! TestArchiverObject
        XCTAssertEqual(object, cloned)
    }
}

class NSSecureKeyedArchiverTests: XCTestCase {
    func testSecureArchiving() {
        let testObject = SecureTestArchiverObject(testingProperty: "Hello")
        let secured = NSKeyedArchiver.MPL_securelyArchivedData(withRootObject: testObject)
        let normal = NSKeyedArchiver.archivedData(withRootObject: testObject)
        XCTAssertEqual(secured, normal)
    }
    
    func testThrowNonSecureArhiving() {
        let testObject = TestArchiverObject(testingProperty: "Hello")
        XCTAssertNoThrow({
            _ = NSKeyedArchiver.MPL_securelyArchivedData(withRootObject: testObject)
        })
    }
    
    func testWriteToFile() {
        let testObject = SecureTestArchiverObject(testingProperty: "Hello")
        
        let path = NSTemporaryDirectory().appending("/hello.bin")
        let success = NSKeyedArchiver.MPL_securelyArchive(rootObject: testObject, to: path)
        let exists = FileManager.default.fileExists(atPath: path)
        XCTAssertTrue(success)
        XCTAssertTrue(exists)
    }
}

class NSSecureKeyedUnarchiverTests: XCTestCase {
    func testUnarchiving() {
        let testObject = SecureTestArchiverObject(testingProperty: "Hello")
        let data = NSKeyedArchiver.MPL_securelyArchivedData(withRootObject: testObject)
        let compare: SecureTestArchiverObject = NSKeyedUnarchiver.MPL_securelyUnarchiveObject(with: data)
        XCTAssertEqual(testObject, compare)
    }
    
    func testNonSecureArchiving() {
        let testObject = TestArchiverObject(testingProperty: "Hello")
        let data = NSKeyedArchiver.archivedData(withRootObject: testObject)
        XCTAssertNoThrow({
            _ = NSKeyedUnarchiver.MPL_securelyUnarchiveObject(with: data) as TestArchiverObject
        })
    }
    
    func testReadingFromFile() {
        let testObject = SecureTestArchiverObject(testingProperty: "Hello")
        
        let path = NSTemporaryDirectory().appending("/hello.bin")
        _ = NSKeyedArchiver.MPL_securelyArchive(rootObject: testObject, to: path)
        
        let cloned: SecureTestArchiverObject? = NSKeyedUnarchiver.MPL_securelyUnarchiveObject(from: path)
        XCTAssertNotNil(cloned)
        XCTAssertEqual(testObject, cloned)
    }
}
