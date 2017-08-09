//
//  SortDescriptorTests.swift
//  MPOLKitTests
//
//  Created by Herli Halim on 10/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

class Person: NSObject  {
    let surname: String
    let firstName: String
    let middleName: String?
    
    init(surname: String, firstName: String, middleName: String?) {
        self.surname = surname
        self.firstName = firstName
        self.middleName = middleName
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Person else {
            return false
        }
        return self.surname == rhs.surname && self.firstName == rhs.firstName && self.middleName == rhs.middleName
    }
}

class SortDescriptorTests: XCTestCase {
    
    let p1 = Person(surname: "Halim", firstName: "Herli", middleName: nil)
    let p2 = Person(surname: "Smith", firstName: "Amber", middleName: "May")
    let p3 = Person(surname: "Smith", firstName: "John", middleName: "Citizen")
    let p4 = Person(surname: "Smith", firstName: "Jones", middleName: "K")
    let p5 = Person(surname: "Halim", firstName: "Herli", middleName: "Chad")
    
    var persons: [Person]!
    
    override func setUp() {
        persons = [p1, p2, p3, p4, p5]
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        persons = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testThatItSortsOnePropertyInAscendingOrder() {
        let sortDescriptor = SortDescriptor<Person>(ascending: true) { $0.surname }
        
        let sorted = persons.sorted(descriptors: [sortDescriptor])
        
        let expected = [p1, p5, p2, p3, p4]
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
