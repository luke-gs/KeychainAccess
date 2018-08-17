//
//  EvaluatorTests.swift
//  MPOLKitTests
//
//  Created by QHMW64 on 30/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import XCTest
@testable import MPOLKit

fileprivate extension Notification.Name {
    static let testNotification = Notification.Name("test")
}

fileprivate extension EvaluatorKey {
    static let test1 = EvaluatorKey(rawValue: "test1")
    static let test2 = EvaluatorKey(rawValue: "test2")
    static let test3 = EvaluatorKey(rawValue: "test3")
    static let test4 = EvaluatorKey(rawValue: "test4")
    static let testThrow = EvaluatorKey(rawValue: "testThrow")
}

class EvaluatorTests: XCTestCase {
    private var evaluatable: DummyEvaluatable?

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        evaluatable = DummyEvaluatable()
        evaluatable?.evaluator.addObserver(evaluatable!)
    }

    func testAddIdentifier() {
        evaluatable?.evaluator.registerKey(.test1, withHandler: { [unowned self] () -> (Bool) in
            return self.evaluatable?.isValid == true
        })
        XCTAssertTrue(evaluatable?.evaluator.totalCount == 1, "Should have a single Identifier")

        evaluatable?.evaluator.registerKey(.test2, withHandler: { [unowned self] () -> (Bool) in
            return self.evaluatable?.isValid == true
        })
        XCTAssertTrue(evaluatable?.evaluator.totalCount == 2, "Should have multiple Identifier")

    }

    func testSingleValidState() {
        evaluatable?.evaluator.registerKey(.test1, withHandler: { () -> (Bool) in
            return true
        })

        XCTAssertTrue(evaluatable?.evaluator.isComplete == true, "Should be valid with single true value")
    }

    func testValidWithMultipleIdentifiers() {

        evaluatable?.evaluator.registerKey(.test2, withHandler: { () -> (Bool) in
            return true
        })
        evaluatable?.evaluator.registerKey(.test3, withHandler: { () -> (Bool) in
            return true
        })

        XCTAssertTrue(evaluatable?.evaluator.isComplete == true, "Should be valid with multiple true values")
    }

    func testEvaluationState() {
        evaluatable?.evaluator.registerKey(.test3, withHandler: { () -> (Bool) in
            return true
        })
        XCTAssertNoThrow(try evaluatable?.evaluator.evaluationState(for: .test3) == true)
        XCTAssertThrowsError(try evaluatable?.evaluator.evaluationState(for: .testThrow) == true)

        do {
            XCTAssertTrue(try evaluatable?.evaluator.evaluationState(for: .test3) == true, "Should return the correct state for test3 identifier")
        }
    }

    func testInvalidEvaluationState() {
        evaluatable?.evaluator.registerKey(.test4, withHandler: { () -> (Bool) in
            return false
        })

        do {
            XCTAssertTrue(try evaluatable?.evaluator.evaluationState(for: .test4) == false, "Should return the false for test4 identifier")
        }

    }

    func testInvalidWithMultipleIdentifiers() {
        evaluatable?.evaluator.registerKey(.test2, withHandler: { () -> (Bool) in
            return true
        })
        evaluatable?.evaluator.registerKey(.test3, withHandler: { () -> (Bool) in
            return true
        })
        evaluatable?.evaluator.registerKey(.test4, withHandler: { () -> (Bool) in
            return false
        })

        XCTAssertTrue(evaluatable?.evaluator.isComplete == false, "Should be false with multiple values where one is false")
    }

    func testEmptyCompletionCount() {
        XCTAssertTrue(evaluatable?.evaluator.completion == 1.0, "Should have a progress of 1.0 when there is nothing registered")
        XCTAssertTrue(evaluatable?.evaluator.validEvaluations == 0, "Should have 0 valid evaluations when nothing is added")
    }

    func testValidCompletionCount() {
        evaluatable?.evaluator.registerKey(.test1, withHandler: { () -> (Bool) in
            return true
        })
        evaluatable?.evaluator.registerKey(.test2, withHandler: { () -> (Bool) in
            return true
        })
        evaluatable?.evaluator.registerKey(.test3, withHandler: { () -> (Bool) in
            return true
        })

        XCTAssertTrue(evaluatable?.evaluator.validEvaluations == 3, "Should have 3 completed evaluations")
        XCTAssertTrue(evaluatable?.evaluator.completion == 1.0, "Should have a completion count of 1.0")
    }

    func testInvalidCompletionCount() {
        evaluatable?.evaluator.registerKey(.test1, withHandler: { () -> (Bool) in
            return true
        })
        evaluatable?.evaluator.registerKey(.test2, withHandler: { () -> (Bool) in
            return true
        })
        evaluatable?.evaluator.registerKey(.test3, withHandler: { () -> (Bool) in
            return true
        })
        evaluatable?.evaluator.registerKey(.test4, withHandler: { () -> (Bool) in
            return false
        })
        XCTAssertTrue(evaluatable?.evaluator.validEvaluations == 3, "Should have 3 completed evaluations, event with one false")
        XCTAssertTrue(evaluatable?.evaluator.totalCount == 4, "Should have 4 total evaluations, event with one false")
        XCTAssertTrue(evaluatable?.evaluator.completion == 0.75, "Should return 3/4 for the state of the evaluator")
    }

    func testObserversNotified() {
        evaluatable?.evaluator.registerKey(.test1, withHandler: { [weak self] () -> (Bool) in
            return self?.evaluatable?.isValid == true
        })

        let x = XCTNSNotificationExpectation(name: .testNotification, object: evaluatable, notificationCenter: .default)
        evaluatable?.isValid = true
        wait(for: [x], timeout: 5)

        evaluatable?.evaluator.removeObserver(evaluatable!)
    }

    func testAddingObservers() {
        XCTAssertTrue(evaluatable?.evaluator.observerCount == 1, "Should have been set up with 1 observer")

        let newObserver: DummyEvaluatable? = DummyEvaluatable()
        evaluatable?.evaluator.addObserver(newObserver!)
        XCTAssertTrue(evaluatable?.evaluator.observerCount == 2, "Should have two unique observers")
    }

    func testUniqueObserver() {

        // Evaluatable is set up with itself as an observer
        // Adding another object with the same reference should not create a new observer
        evaluatable?.evaluator.addObserver(evaluatable!)
        evaluatable?.evaluator.addObserver(evaluatable!)
        XCTAssert(evaluatable?.evaluator.observerCount == 1, "Should still only have one unique observer")
    }

    func testRemoveObserver() {
        evaluatable?.evaluator.removeObserver(evaluatable!)
        XCTAssert(evaluatable?.evaluator.observerCount == 0, "Should have no observers")
    }

}

fileprivate class DummyEvaluatable: EvaluationObserverable {
    let evaluator: Evaluator = Evaluator()

    var isValid: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .test1)
        }
    }

    // Dummy notifcation is posted to ensure that observers are ntoified upon changes
    func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        NotificationCenter.default.post(name: .testNotification, object: self, userInfo: nil)
    }
}
