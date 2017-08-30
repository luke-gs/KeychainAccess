//
//  FilterDescriptorTests.swift
//  MPOLKitTests
//
//  Created by Megan Efron on 30/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

enum Gender {
    case female, male, unknown
}

class Human: NSObject  {
    let surname: String
    let age: Int
    let gender: Gender
    
    init(surname: String, age: Int, gender: Gender) {
        self.surname = surname
        self.age = age
        self.gender = gender
    }
}

// Sorry for the shitty tests
class FilterDescriptorTests: XCTestCase {
    
    let p1 = Human(surname: "Halim", age: 12, gender: .male)
    let p2 = Human(surname: "Smith", age: 25, gender: .male)
    let p3 = Human(surname: "Scott", age: 28, gender: .female)
    let p4 = Human(surname: "Test", age: 50, gender: .unknown)
    let p5 = Human(surname: "Efron", age: 75, gender: .female)
    
    var persons: [Human]!
    
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
    
    func testFilterBySurname() {
        let values: Set = ["Halim", "Smith", "Efron"]
        let filterDescriptor = FilterDescriptor<Human>(key: { $0.surname }, values: values)
        
        let filtered = persons.filter(using: [filterDescriptor])
        
        for person in persons {
            if values.contains(person.surname) {
                XCTAssert(filtered.contains(person))
            } else {
                XCTAssert(!filtered.contains(person))
            }
        }
    }
    
    func testFilterByAge() {
        let values: Set = [25, 50, 75]
        let filterDescriptor = FilterDescriptor<Human>(key: { $0.age }, values: values)
        
        let filtered = persons.filter(using: [filterDescriptor])
        
        for person in filtered {
            if values.contains(person.age){
                XCTAssert(filtered.contains(person))
            } else {
                XCTAssert(!filtered.contains(person))
            }
        }
    }
    
    func testFilterByGender() {
        let values: Set<Gender> = [.female, .male]
        let filterDescriptor = FilterDescriptor<Human>(key: { $0.gender }, values: values)
        
        let filtered = persons.filter(using: [filterDescriptor])
        
        for person in filtered {
            if values.contains(person.gender){
                XCTAssert(filtered.contains(person))
            } else {
                XCTAssert(!filtered.contains(person))
            }
        }
    }
    
    func testFilterBySurnameAndAge() {
        let surnames: Set = ["Halim", "Smith", "Scott", "Efron"]
        let ages: Set = [12, 75]
        
        let surnameDescriptor = FilterDescriptor<Human>(key: { $0.surname }, values: surnames)
        let ageDescriptor = FilterDescriptor<Human>(key: { $0.age }, values: ages)
        
        let filtered = persons.filter(using: [surnameDescriptor, ageDescriptor])
        
        let expected = ["Halim", "Efron"]
        let notExpected = ["Smith", "Scott", "Test"]
        
        for person in filtered {
            print(person)
        }
        
        for person in persons {
            if filtered.contains(person) {
                XCTAssert(expected.contains(person.surname))
            } else {
                XCTAssert(notExpected.contains(person.surname))
            }
        }
    }
    
    func testFilterBySurnameAndAgeAndGender() {
        let surnames: Set = ["Halim", "Smith", "Scott", "Efron"]
        let ages: Set = [12, 75]
        let genders: Set<Gender> = [.female]
        
        let surnameDescriptor = FilterDescriptor<Human>(key: { $0.surname }, values: surnames)
        let ageDescriptor = FilterDescriptor<Human>(key: { $0.age }, values: ages)
        let genderDescriptor = FilterDescriptor<Human>(key: { $0.gender }, values: genders)
        
        let filtered = persons.filter(using: [surnameDescriptor, ageDescriptor, genderDescriptor])
        
        let expected = ["Efron"]
        let notExpected = ["Smith", "Scott", "Test", "Halim"]
        
        for person in persons {
            if filtered.contains(person) {
                XCTAssert(expected.contains(person.surname))
            } else {
                XCTAssert(notExpected.contains(person.surname))
            }
        }
    }
    
}
