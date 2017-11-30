//
//  Evaluator.swift
//  MPOLKit
//
//  Created by QHMW64 on 30/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

@objc public class Evaluator: NSObject {

    public typealias EvaluationHandler = () -> (Bool)
    public typealias EvaluationIdentifier = String

    private var evaluators: [EvaluationIdentifier: EvaluationHandler] = [:]
    private var evaluationStates: [EvaluationIdentifier: Bool] = [:]

    // Using a hashtable allows for weak references to
    // be held for the blocks avoiding retain cycle
    private var observers = NSHashTable<EvaluationObserverable>(options: .weakMemory)

    // MARK: - Completion

    /// Checks and returns whether all the registered validation states
    /// for this validator are valid. Returns false if any are false and true only if all are true
    public var isComplete: Bool {
        for state in evaluationStates.values where state == false {
            return state
        }
        return true
    }

    /// The percentage completion of the validator
    public var completion: Float {
        let count = Float(evaluationStates.values.count)
        return count == 0 ? 1.0 : Float(validEvaluations) / count
    }

    /// The total count of the states for states
    public var totalCount: Int {
        return evaluationStates.count
    }

    /// The current count of the completion of the validator
    public var validEvaluations: Int {
        var count = 0
        evaluationStates.values.forEach { if $0 { count += 1 } }
        return count
    }

    public var observerCount: Int {
        return observers.count
    }

    // MARK: - Registration

    /// Registers an identifier with a block to be called when changes occur
    ///
    /// - Parameters:
    ///   - identifier: String The value to store the block against
    ///   - handler: The block that will be called when an soemthing triggers a change to occur
    public func registerIdentifier(_ identifier: EvaluationIdentifier, withHandler handler: @escaping EvaluationHandler) {
        evaluators[identifier] = handler
        evaluationStates[identifier] = handler()
    }


    /// The last stored value of the validation state for a specific identifier
    ///
    /// - Parameter identifier: A key used to check for a specific validation state
    /// - Returns: The state of validation, either true or false
    public func evaluationState(for identifier: EvaluationIdentifier) -> Bool {
        return evaluationStates[identifier] ?? true
    }

    /// Adds a validation state given that the state exists
    ///
    /// - Parameters:
    ///   - validationState: The state passed in to be set
    ///   - identifier: The key for the specific validation state
    public func addEvaluation(_ evaluationState: Bool, for identifier: EvaluationIdentifier) {
        if let state = evaluationStates[identifier] {
            if state != evaluationState {
                evaluationStates[identifier] = evaluationState
                notifyObservers(that: identifier, changedTo: evaluationState)
            }
        }
    }

    /// Update the validation state for each identifier provided
    ///
    /// - Parameter identifiers: An array of identifiers used to know which
    ///             state to update
    public func updateEvaluation(for identifiers: [EvaluationIdentifier]) {
        identifiers.forEach { evaluate(for: $0) }
    }

    /// Update the validation state for the identifier provided
    ///
    /// - Parameter identifier: An single instance of an identifiers used to know which
    ///             state to update
    public func updateEvaluation(for identifier: EvaluationIdentifier) {
        evaluate(for: identifier)
    }

    /// Notify all the observers that a change has occurred for an identifier
    ///
    /// - Parameters:
    ///   - identifier: The specific key for the change
    ///   - state: The state that the change caused to be set
    public func notifyObservers(that identifier: EvaluationIdentifier, changedTo state: Bool) {
        observers.allObjects.forEach {
            $0.evaluationChanged(in: self, for: identifier, evaluationState: state)
        }
    }

    /// Adds an observer to the hashTable of observers
    ///
    /// - Parameter observer: The observer must be an ObserverProtocol
    public func addObserver(_ observer: EvaluationObserverable) {
        observers.add(observer)
    }

    /// Removes an observer from the hashTable of observers
    ///
    /// - Parameter observer: The observer must be an ObserverProtocol
    public func removeObserver(_ observer: EvaluationObserverable) {
        observers.remove(observer)
    }

    /// Evaluates and returns the state of the stored block for a specific identifier
    /// If the evaluators contain a block for the identifier it calls the block and
    /// stores that value as the last known state for that identifier/block
    /// If it does not contain a block anymore (may have gone out of scope), returns the
    /// last known state if it exists
    ///
    /// - Parameter identifier: The key to the specific identifier
    /// - Returns: The state of the validation for that identifier
    @discardableResult
    private func evaluate(for identifier: EvaluationIdentifier) -> Bool {
        var isValid = true
        if let handler = evaluators[identifier] {
            isValid = handler()
            addEvaluation(isValid, for: identifier)
        } else {
            if let state = evaluationStates[identifier] {
                isValid = state
            }
        }
        return isValid
    }
}
