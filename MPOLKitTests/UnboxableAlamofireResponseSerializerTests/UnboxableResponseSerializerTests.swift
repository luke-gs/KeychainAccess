//
//  UnboxableAlamofireResponseSerializerTests.swift
//  MPOLKit
//
//  Created by Herli Halim on 18/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

@testable import MPOLKit
import XCTest
import Alamofire

class UnboxableAlamofireResponseSerializerTests: XCTestCase {
    
    var bundle: Bundle!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        bundle = Bundle(for: type(of: self))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        bundle = nil
    }
    
    func testMappingObject() {
        
        let url = bundle.url(forResource: "SimplePerson", withExtension: "json")!
        
        Alamofire.request(url).responseObject { (response: DataResponse<SimplePerson>) in
            
            let person = response.value
            XCTAssertNotNil(person, "Response shouldn't be nil")
            XCTAssertNil(response.result.error)
            XCTAssertEqual(person?.firstName, "Herli")
            XCTAssertEqual(person?.surname, "Halim")
            
        }
        
    }
    
    func testMappingObjectUsingKeyPath() {
        
        let url = bundle.url(forResource: "SimplePersonKeyPath", withExtension: "json")!
        
        Alamofire.request(url).responseObject(keyPath: "value") { (response: DataResponse<SimplePerson>) in
            
            let person = response.value
            XCTAssertNotNil(person, "Response shouldn't be nil")
            XCTAssertNil(response.result.error)
            XCTAssertEqual(person?.firstName, "Herli")
            XCTAssertEqual(person?.surname, "Halim")
            
        }
        
    }
    
    func testMappingObjectUsingNestedKeyPath() {
        
        let url = bundle.url(forResource: "SimplePersonNestedKeyPath", withExtension: "json")!
        
        Alamofire.request(url).responseObject(keyPath: "result.person") { (response: DataResponse<SimplePerson>) in
            
            let person = response.value
            XCTAssertNotNil(person, "Response shouldn't be nil")
            XCTAssertNil(response.result.error)
            XCTAssertEqual(person?.firstName, "Herli")
            XCTAssertEqual(person?.surname, "Halim")
            
        }
        
    }
    
    func testMappingArrayOfObjects() {
        let url = bundle.url(forResource: "SimplePersonArray", withExtension: "json")!
        
        Alamofire.request(url).responseArray { (response: DataResponse<[SimplePerson]>) in
            
            let persons = response.value
 
            XCTAssertNotNil(persons, "Response shouldn't be nil")
            XCTAssertNil(response.result.error)
            XCTAssertEqual(persons?.count, 2)
            
        }
    }
    
    func testMappingArrayOfObjectsUsingKeyPath() {
        let url = bundle.url(forResource: "SimplePersonArrayKeyPath", withExtension: "json")!
        
        Alamofire.request(url).responseArray(keyPath: "values") { (response: DataResponse<[SimplePerson]>) in
            
            let persons = response.value
            
            XCTAssertNotNil(persons, "Response shouldn't be nil")
            XCTAssertNil(response.result.error)
            XCTAssertEqual(persons?.count, 2)
            
        }
    }
    
    func testMappingArrayOfObjectsUsingNestedKeyPath() {
        
        let url = bundle.url(forResource: "SimplePersonArrayNestedKeyPath", withExtension: "json")!
        
        Alamofire.request(url).responseArray(keyPath: "result.values") { (response: DataResponse<[SimplePerson]>) in
            
            let persons = response.value
            
            XCTAssertNotNil(persons, "Response shouldn't be nil")
            XCTAssertNil(response.result.error)
            XCTAssertEqual(persons?.count, 2)
            
        }
        
    }
    
}
