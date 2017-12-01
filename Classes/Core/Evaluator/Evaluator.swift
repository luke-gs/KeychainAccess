//
//  Evaluator.swift
//  MPOLKit
//
//  Created by QHMW64 on 30/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

final public class Evaluator {

    public typealias EvaluationHandler = () -> (Bool)

    private var evaluators: [EvaluatorKey: EvaluationHandler] = [:]
    private var evaluationStates: [EvaluatorKey: Bool] = [:]

    private var observers = [WeakObservableWrapper]()

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

    /// Registers a key with a block to be called when changes occur
    ///
    /// - Parameters:
    ///   - identifier: String The value to store the block against
    ///   - handler: The block that will be called when an soemthing triggers a change to occur
    public func registerKey(_ key: EvaluatorKey, withHandler handler: @escaping EvaluationHandler) {
        evaluators[key] = handler
        evaluationStates[key] = handler()
    }


    /// The last stored value of the validation state for a specific key
    ///
    /// - Parameter key: A key used to check for a specific validation state
    /// - Returns: The state of validation, either true or false
    public func evaluationState(for key: EvaluatorKey) -> Bool {
        return evaluationStates[key] ?? true
    }

    /// Adds a validation state given that the state exists
    ///
    /// - Parameters:
    ///   - validationState: The state passed in to be set
    ///   - identifier: The key for the specific validation state
    public func addEvaluation(_ evaluationState: Bool, for key: EvaluatorKey) {
        if let state = evaluationStates[key] {
            if state != evaluationState {
                evaluationStates[key] = evaluationState
                notifyObservers(that: key, changedTo: evaluationState)
            }
        }
    }

    /// Update the validation state for each identifier provided
    ///
    /// - Parameter keys: An array of keys used to know which
    ///             state to update
    public func updateEvaluation(for keys: [EvaluatorKey]) {
        keys.forEach { evaluate(for: $0) }
    }

    /// Update the validation state for the identifier provided
    ///
    /// - Parameter key: An single instance of a key used to know which
    ///             state to update
    public func updateEvaluation(for key: EvaluatorKey) {
        evaluate(for: key)
    }

    /// Notify all the observers that a change has occurred for an identifier
    ///
    /// - Parameters:
    ///   - identifier: The specific key for the change
    ///   - state: The state that the change caused to be set
    public func notifyObservers(that key: EvaluatorKey, changedTo state: Bool) {
        observers.forEach {
            $0.value?.evaluationChanged(in: self, for: key, evaluationState: state)
        }
    }

    /// Adds an observer to the hashTable of observers
    ///
    /// - Parameter observer: The observer must be an ObserverProtocol
    public func addObserver(_ observer: EvaluationObserverable) {
        if observers.contains(where: { $0.value === observer }) == false {
            observers.append(WeakObservableWrapper(value: observer))
        }
    }

    /// Removes an observer from the hashTable of observers
    ///
    /// - Parameter observer: The observer must be an ObserverProtocol
    public func removeObserver(_ observer: EvaluationObserverable) {
        if let index = observers.index(where: { $0.value === observer }) {
            observers.remove(at: index)
        }
    }

    /// Evaluates and returns the state of the stored block for a specific identifier
    /// If the evaluators contain a block for the identifier it calls the block and
    /// stores that value as the last known state for that identifier/block
    /// If it does not contain a block anymore (may have gone out of scope), returns the
    /// last known state if it exists
    ///
    /// - Parameter key: The key to the specific key
    /// - Returns: The state of the validation for that key
    @discardableResult
    private func evaluate(for key: EvaluatorKey) -> Bool {
        var isValid = true
        if let handler = evaluators[key] {
            isValid = handler()
            addEvaluation(isValid, for: key)
        } else {
            if let state = evaluationStates[key] {
                isValid = state
            }
        }
        return isValid
    }
}

/// Instead of using a Hashtable, wrap the EvaluationObserverable in a container
/// that holds a weak reference to the value
fileprivate struct WeakObservableWrapper {

    private weak var _value: EvaluationObserverable?

    init(value: EvaluationObserverable) {
        _value = value
    }

    var value: EvaluationObserverable? {
        return _value
    }
}
