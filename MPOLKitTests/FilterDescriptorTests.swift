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
    
    func testValueFilterBySurname() {
        let values: Set = ["Halim", "Smith", "Efron"]
        let filterDescriptor = FilterValueDescriptor<Human>(key: { $0.surname }, values: values)
        
        let filtered = persons.filter(using: [filterDescriptor])
        let notExpected: Set = ["Scott", "Test"]
        
        for person in persons {
            if filtered.contains(person){
                XCTAssert(values.contains(person.surname))
            } else {
                XCTAssert(notExpected.contains(person.surname))
            }
        }
    }
    
    func testRangeFilterByAge() {
        let filterDescriptor = FilterRangeDescriptor<Human>(key: { $0.age }, start: 20, end: 60)
        
        let filtered = persons.filter(using: [filterDescriptor])
        let expected: Set = ["Smith", "Scott", "Test"]
        let notExpected: Set = ["Halim", "Efron"]
        
        for person in persons {
            if filtered.contains(person){
                XCTAssert(expected.contains(person.surname))
            } else {
                XCTAssert(notExpected.contains(person.surname))
            }
        }
    }
    
    func testValueFilterByGender() {
        let values: Set<Gender> = [.female, .male]
        let filterDescriptor = FilterValueDescriptor<Human>(key: { $0.gender }, values: values)
        
        let filtered = persons.filter(using: [filterDescriptor])
        let expected: Set = ["Halim", "Scott", "Smith", "Efron"]
        let notExpected: Set = ["Test"]
        
        for person in persons {
            if filtered.contains(person){
                XCTAssert(expected.contains(person.surname))
            } else {
                XCTAssert(notExpected.contains(person.surname))
            }
        }
    }
    
    func testFilterBySurnameAndAge() {
        let surnames: Set = ["Halim", "Smith", "Scott", "Efron"]
        
        let surnameDescriptor = FilterValueDescriptor<Human>(key: { $0.surname }, values: surnames)
        let ageDescriptor = FilterRangeDescriptor<Human>(key: { $0.age }, start: 20, end: 60)
        
        let filtered = persons.filter(using: [surnameDescriptor, ageDescriptor])
        
        let expected = ["Smith", "Scott"]
        let notExpected = ["Halim", "Efron", "Test"]
        
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
        let genders: Set<Gender> = [.female]
        
        let surnameDescriptor = FilterValueDescriptor<Human>(key: { $0.surname }, values: surnames)
        let ageDescriptor = FilterRangeDescriptor<Human>(key: { $0.age }, start: 20, end: 60)
        let genderDescriptor = FilterValueDescriptor<Human>(key: { $0.gender }, values: genders)
        
        let filtered = persons.filter(using: [surnameDescriptor, ageDescriptor, genderDescriptor])
        
        let expected = ["Scott"]
        let notExpected = ["Smith", "Efron", "Test", "Halim"]
        
        for person in persons {
            if filtered.contains(person) {
                XCTAssert(expected.contains(person.surname))
            } else {
                XCTAssert(notExpected.contains(person.surname))
            }
        }
    }
    
}
