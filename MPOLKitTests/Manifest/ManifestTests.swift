//
//  ManifestTests.swift
//  MPOLKitTests
//
//  Created by Valery Shorinov on 21/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class ManifestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testManifestSaveAndRetrieve () {
        guard let fileURL = Bundle(for: ManifestTests.self).url(forResource: "manifestItems", withExtension: "json"),
            let manifestArray = (try? JSONSerialization.jsonObject(with: Data(contentsOf: fileURL))) as? [[String: Any]]
            else {
                XCTFail("Manifest Error: parsing test JSON or Cannot find file")
                return
        }
        
        Manifest.shared.saveManifest(with: manifestArray, at: Date(), completion: { error in
            if let error = error {
                XCTFail("Manifest Error: \(error.localizedDescription)")
            } else {
                for item in manifestArray {
                    if let id = item["id"] as? String {
                        if let fetchedItem = Manifest.shared.entry(withID: id) {
                            XCTAssertEqual(fetchedItem.id, id)
                            if let active = item["active"] as? Bool {
                                XCTAssertEqual(fetchedItem.active, active)
                            } else {
                                XCTFail("Manifest Error: Active cannot be nil")
                            }
                            if let category = item["category"] as? String {
                                XCTAssertEqual(fetchedItem.collection, category)
                            } else {
                                XCTAssertEqual(fetchedItem.collection, nil)
                            }
                            if let title = item["title"] as? String {
                                XCTAssertEqual(fetchedItem.title, title)
                            } else {
                                XCTAssertEqual(fetchedItem.title, nil)
                            }
                            if let subtitle = item["subtitle"] as? String {
                                XCTAssertEqual(fetchedItem.subtitle, subtitle)
                            } else {
                                XCTAssertEqual(fetchedItem.subtitle, nil)
                            }
                            if let shortTitle = item["shortTitle"] as? String {
                                XCTAssertEqual(fetchedItem.shortTitle, shortTitle)
                            } else {
                                XCTAssertEqual(fetchedItem.shortTitle, nil)
                            }
                            if let rawValue = item["value"] as? String {
                                XCTAssertEqual(fetchedItem.rawValue, rawValue)
                            } else {
                                XCTAssertEqual(fetchedItem.rawValue, nil)
                            }
                            if let sortOrder = item["sortOrder"] as? Double {
                                XCTAssertEqual(fetchedItem.sortOrder, sortOrder)
                            } else {
                                XCTAssertEqual(fetchedItem.sortOrder, nil)
                            }
                            
                            if let effectiveTI = item["effectiveDate"] as? TimeInterval {
                                XCTAssertEqual(fetchedItem.effectiveDate, NSDate(timeIntervalSince1970: effectiveTI))
                            } else {
                                XCTAssertEqual(fetchedItem.effectiveDate, nil)
                            }
                            
                            if let expiryTI = item["expiryDate"] as? TimeInterval {
                                XCTAssertEqual(fetchedItem.expiryDate, NSDate(timeIntervalSince1970: expiryTI))
                            } else {
                                XCTAssertEqual(fetchedItem.expiryDate, nil)
                            }
                            
                            if let lastUpdatedTI = item["dateLastUpdated"] as? TimeInterval {
                                XCTAssertEqual(fetchedItem.lastUpdated, NSDate(timeIntervalSince1970: lastUpdatedTI))
                            } else {
                                XCTAssertEqual(fetchedItem.lastUpdated, nil)
                            }
                            
                            if var additionalData = item["additionalData"] as? [String: Any] {
                                
                                if let latitude = additionalData["latitude"] as? NSNumber {
                                    XCTAssertEqual(fetchedItem.latitude, latitude)
                                    additionalData.removeValue(forKey: "latitude")
                                } else {
                                    XCTAssertEqual(fetchedItem.latitude, nil)
                                }
                                
                                if let longitude = additionalData["longitude"] as? NSNumber {
                                    XCTAssertEqual(fetchedItem.longitude, longitude)
                                    additionalData.removeValue(forKey: "longitude")
                                } else {
                                    XCTAssertEqual(fetchedItem.longitude, nil)
                                }
                                
                                if let newData = try? JSONSerialization.data(withJSONObject: additionalData), let json = String(data: newData, encoding: .utf8) {
                                    XCTAssertEqual(fetchedItem.additionalData, json)
                                } else {
                                    XCTAssertEqual(fetchedItem.additionalData, nil)
                                }
                            } else {
                                XCTAssertEqual(fetchedItem.additionalData, nil)
                            }
                        } else {
                            XCTFail("Manifest Error: Unable to find item")
                        }
                        
                    }
                }
                
            }
        })
    }
    
}
