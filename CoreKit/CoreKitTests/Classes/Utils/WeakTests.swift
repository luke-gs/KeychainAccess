//
//  WeakTests.swift
//  MPOLKitTests
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

import XCTest


@objc(MPOLKITTestsDummyObject) private class DummyObject: NSObject, NSSecureCoding {

    override func isEqual(_ object: Any?) -> Bool {
        guard let dummy = object as? DummyObject else { return false }
        return property == dummy.property
    }

    static var supportsSecureCoding: Bool {
        return true
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(property, forKey: "property")
    }

    required init?(coder aDecoder: NSCoder) {
        property = (aDecoder.decodeObject(of: NSString.self, forKey: "property") as String?)!
    }
    var property: String = UUID().uuidString

    public override init() {
        super.init()
    }
}

class WeakTests: XCTestCase {

    private var object = DummyObject()
    private lazy var weakObject = Weak(object)

    func testSecureCoding() {
        guard let obj = weakObject.object else {
            XCTFail("Should not have a nil object reference")
            return
        }
        let weakData = NSKeyedArchiver.MPL_securelyArchivedData(withRootObject: obj)
        guard let comparison: DummyObject = NSKeyedUnarchiver.MPL_securelyUnarchiveObject(with: weakData) else {
            XCTFail("Should be able to unarchive correctly")
            return
        }
        let restoredObject = Weak(comparison)
        XCTAssertEqual(weakObject.object, restoredObject.object)
    }

}
