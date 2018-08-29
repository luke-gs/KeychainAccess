//
//  SortDescriptorTests.swift
//  MPOLKitTests
//
//  Created by Herli Halim on 10/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest


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

    override var description: String {
        let superDescription = super.description
        return "\(superDescription) - \(firstName) \(String(describing: middleName)) \(surname)"
    }
}

class SortDescriptorTests: XCTestCase {
    
    let p1 = Person(surname: "Halim", firstName: "Herli", middleName: nil)
    let p2 = Person(surname: "Smith", firstName: "Amber", middleName: "May")
    let p3 = Person(surname: "Smith", firstName: "John", middleName: "Citizen")
    let p4 = Person(surname: "Smith", firstName: "Jones", middleName: "K")
    let p5 = Person(surname: "Halim", firstName: "Herli", middleName: "Chad")
    let p6 = Person(surname: "Halim", firstName: "herli", middleName: nil)
    
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
        
        let sorted = persons.sorted(using: [sortDescriptor])
        let expected = ["Halim", "Halim", "Smith", "Smith", "Smith"]
        
        for (index, person) in sorted.enumerated() {
            // Only check `surname` because we only sort by `surname`.
            let current = person.surname
            let expect = expected[index]
            XCTAssertEqual(current, expect)
        }
    }
    
    func testThatItSortsMultiplePropertInDescendingOrder() {
        let sortDescriptor = SortDescriptor<Person>(ascending: false) { $0.surname }
        
        let sorted = persons.sorted(using: [sortDescriptor])
        let expected = ["Smith", "Smith", "Smith", "Halim", "Halim"]
        
        for (index, person) in sorted.enumerated() {
            // Only check `surname` because we only sort by `surname`.
            let current = person.surname
            let expect = expected[index]
            XCTAssertEqual(current, expect)
        }
    }
    
    func testThatItSortsMultiplePropertiesInAscendingOrder() {
        let surnameDescriptor = SortDescriptor<Person>(ascending: true) { $0.surname }
        let firstNameDescriptor = SortDescriptor<Person>(ascending: true) { $0.firstName }
        let sorted = persons.sorted(using: [surnameDescriptor, firstNameDescriptor])
        
        let expected = [(surname: "Halim", firstName: "Herli"),
                        (surname: "Halim", firstName: "Herli"),
                        (surname: "Smith", firstName: "Amber"),
                        (surname: "Smith", firstName: "John"),
                        (surname: "Smith", firstName: "Jones"),
                        ]
        
        for (index, person) in sorted.enumerated() {
            
            let expect = expected[index]
            // Only check `surname` and `firstName` because we only sort by `surname` then `firstName`.
            XCTAssertEqual(person.surname, expect.surname)
            XCTAssertEqual(person.firstName, expect.firstName)
        }
    }
    
    func testThatItSortsMultiplePropertiesInDescendingOrder() {
        let surnameDescriptor = SortDescriptor<Person>(ascending: false) { $0.surname }
        let firstNameDescriptor = SortDescriptor<Person>(ascending: false) { $0.firstName }
        let sorted = persons.sorted(using: [surnameDescriptor, firstNameDescriptor])
        
        let expected = [(surname: "Smith", firstName: "Jones"),
                        (surname: "Smith", firstName: "John"),
                        (surname: "Smith", firstName: "Amber"),
                        (surname: "Halim", firstName: "Herli"),
                        (surname: "Halim", firstName: "Herli"),
                        ]
        
        for (index, person) in sorted.enumerated() {
            // Only check `surname` and `firstName` because we only sort by `surname` then `firstName`.
            let expect = expected[index]
            XCTAssertEqual(person.surname, expect.surname)
            XCTAssertEqual(person.firstName, expect.firstName)
        }
    }

    func testThatItSortsPropertyCorrectlyUsingCustomComparator() {

        let descriptor = SortDescriptor<Person>(ascending: true, comparator: {
            return $0.firstName.localizedCompare($1.firstName)
        })
        let sorted = persons.sorted(using: [descriptor])

        let expected = [ "Amber", "Herli", "Herli", "John", "Jones", "herli" ]

        for (index, person) in sorted.enumerated() {

            let expect = expected[index]
            // Only check `firstName` because we only sort by `firstName`.
            XCTAssertEqual(person.firstName, expect)
        }

    }
    
    func testThatItSortsNilPropertyFirst() {
        let surnameDescriptor = SortDescriptor<Person>(ascending: true) { $0.surname }
        let firstNameDescriptor = SortDescriptor<Person>(ascending: true) { $0.firstName }
        let middleNameDescriptor = SortDescriptor<Person>(ascending: true) { $0.middleName }
        
        let sorted = persons.sorted(using: [surnameDescriptor, firstNameDescriptor, middleNameDescriptor])
        
        let expected = [p1, p5, p2, p3, p4]
        
        for (index, person) in sorted.enumerated() {
            let expect = expected[index]
            XCTAssertEqual(person, expect)
        }
    }
    
    func testThatItSortsNilPropertyLast() {
        let surnameDescriptor = SortDescriptor<Person>(ascending: true) { $0.surname }
        let firstNameDescriptor = SortDescriptor<Person>(ascending: true) { $0.firstName }
        let middleNameDescriptor = SortDescriptor<Person>(ascending: false) { $0.middleName }
        
        let sorted = persons.sorted(using: [surnameDescriptor, firstNameDescriptor, middleNameDescriptor])
        
        let expected = [p5, p1, p2, p3, p4]
        
        for (index, person) in sorted.enumerated() {
            let expect = expected[index]
            XCTAssertEqual(person, expect)
        }
    }

    func testThatNilValueSortDescriptorSortsNil() {
        let nilDescriptor = SortDescriptor<Person>.nilValueSortDescriptor(nilFirst: false) { $0.middleName }
        let sorted = persons.sorted(using: [nilDescriptor])

        XCTAssertEqual(sorted.last!, p1)
    }
}
