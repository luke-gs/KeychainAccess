//
//  LocationAdvanceOptions.swift
//  MPOLKit
//
//  Created by KGWH78 on 31/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol LocationAdvanceOptions: SearchOptions {
    
    /// The title of the cancel button.
    var cancelTitle: String { get }
    
    /// Creates a picker controller for filter at index. This is called if the 
    /// filter type is 'picker'.
    ///
    /// - Parameters:
    ///   - index: The filter index.
    ///   - updateHandler: The update handler. Call updateHandler to notify that the value has changed.
    /// - Returns: The controller to be presented.
    func pickerController(forFilterAt index: Int, updateHandler: @escaping () -> ()) -> UIViewController?
    
    /// Update existing options with new values. 
    ///
    /// - Parameters:
    ///   - options: The options
    ///   - reset: If true, this should reset all values to default if not present in the options.
    ///            If false, only updates values specified in the options.
    func populate(withOptions options: [Int: String]?, reset: Bool)
    
    /// The textual presentation of the LocationAdvanceOptions. Used to create a searchable and therefore
    /// should be user friendly.
    ///
    /// - Returns: A user friendly text.
    func textRepresentation() -> String?
    
    /// Update existing options with values from location.
    ///
    /// - Parameters:
    ///   - location: The Location.
    func populate(withLocation location: LookupAddress)
}
