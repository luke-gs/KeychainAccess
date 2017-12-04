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
    /// Will throw when attempting to retrieve state for a key that doesn't exist
    ///
    /// - Parameter key: A key used to check for a specific validation state
    /// - Returns: The state of validation, either true or false
    public func evaluationState(for key: EvaluatorKey) throws -> Bool {
        guard let state = evaluationStates[key] else {
            throw EvaluationError.invalidKey
        }
        return state
    }

    /// Adds a validation state given that the state exists
    /// Will throw when provided a key that doesn't exist in the stored states
    ///
    /// - Parameters:
    ///   - validationState: The state passed in to be set
    ///   - identifier: The key for the specific validation state
    public func addEvaluation(_ evaluationState: Bool, for key: EvaluatorKey) throws {
        guard let state = evaluationStates[key] else {
            throw EvaluationError.invalidKey
        }
        if state != evaluationState {
            evaluationStates[key] = evaluationState
            notifyObservers(that: key, changedTo: evaluationState)
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
    /// and removes any observer that has been released
    ///
    /// - Parameters:
    ///   - identifier: The specific key for the change
    ///   - state: The state that the change caused to be set
    public func notifyObservers(that key: EvaluatorKey, changedTo state: Bool) {
        observers.forEach {
            $0.value?.evaluationChanged(in: self, for: key, evaluationState: state)
        }
        observers = observers.removeNilObservers()
    }

    /// Adds an observer to the array of observers, an array of weak wrappers
    /// around evaluationObservables, removes any observer that has been released
    /// - Parameter observer: The observer must be an EvaluationObserverable
    public func addObserver(_ observer: EvaluationObserverable) {
        if observers.contains(where: { $0.value === observer }) == false {
            observers.append(WeakObservableWrapper(value: observer))
        }
        observers = observers.removeNilObservers()
    }

    /// Removes an observer from the hashTable of observers and
    /// removes any observer that has been released
    ///
    /// - Parameter observer: The observer must be an ObserverProtocol
    public func removeObserver(_ observer: EvaluationObserverable) {
        if let index = observers.index(where: { $0.value === observer }) {
            observers.remove(at: index)
        }
        observers = observers.removeNilObservers()
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
            do {
                try addEvaluation(isValid, for: key)
            } catch {
                isValid = false
            }
        } else {
            if let state = evaluationStates[key] {
                isValid = state
            }
        }
        return isValid
    }
}

fileprivate extension Array where Element == WeakObservableWrapper {

    /// This function is needed to ensure that if the values of the Weak
    /// observerable Wrapper are nil they are removed from the array, much
    /// like how NSHashTable works.
    func removeNilObservers() -> [Element] {
        return filter { $0.value != nil }
    }
}

/// Instead of using a Hashtable, wrap the EvaluationObserverable in a container
/// that holds a weak reference to the value
fileprivate class WeakObservableWrapper {

    private weak var _value: EvaluationObserverable?

    init(value: EvaluationObserverable) {
        _value = value
    }

    var value: EvaluationObserverable? {
        return _value
    }
}
